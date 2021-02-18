function Efield_BCs(p, xg)
arguments
  p (1,1) struct
  xg (1,1) struct
end

% Set input potential/FAC boundary conditions and write these to a set of
% files that can be used an input to GEMINI.  This is a basic examples that
% can make Gaussian shaped potential or FAC inputs using an input width.

dir_out = p.E0_dir;
gemini3d.fileio.makedir(dir_out);

lx1 = xg.lx(1);
lx2 = xg.lx(2);
lx3 = xg.lx(3);


%% For current density boundary conditions we need to determin top v bottom of the grid
if (xg.alt(1,1,1)>xg.alt(2,1,1))
    gridflag=1;    % inverted
    disp(" Efield_BCs:  Detected an inverted grid...");
else
    gridflag=2;    % non-inverted or closed
    disp(" Efield_BCs:  Detected a non-inverted grid...");
end %if

%% determine what type of grid (cartesian or dipole) we are dealing with
if (any(xg.h1>1.01))
    flagdip=true;
    disp(' Efield_BCs:  Dipole grid detected...');
else
    flagdip=false;
    disp(' Efield_BCs:  Cartesian grid detected...');
end %if


%% number of points for input data
E.llon=100;
E.llat=100;
if (flagdip)
    if lx3 == 1
        E.llon=1;
    elseif lx2==1
        E.llat=1;        
    end %if
else
    if lx2 == 1
        E.llon = 1;
    elseif lx3 == 1
        E.llat = 1;
    end
end %if

thetamin = min(xg.theta(:));
thetamax = max(xg.theta(:));
mlatmin = 90-thetamax*180/pi;
mlatmax = 90-thetamin*180/pi;
mlonmin = min(xg.phi(:))*180/pi;
mlonmax = max(xg.phi(:))*180/pi;

% add a 1% buff
latbuf = 1/100 * (mlatmax-mlatmin);
lonbuf = 1/100 * (mlonmax-mlonmin);
E.mlat = linspace(mlatmin-latbuf, mlatmax+latbuf, E.llat);
E.mlon = linspace(mlonmin-lonbuf, mlonmax+lonbuf, E.llon);
[E.MLON, E.MLAT] = ndgrid(E.mlon, E.mlat);
E.mlonmean = mean(E.mlon);
E.mlatmean = mean(E.mlat);

%% WIDTH OF THE DISTURBANCE
if isfield(p, 'Efield_latwidth')
    if (flagdip)
        [E.mlatsig, E.sigx2] = Esigma(p.Efield_latwidth, mlatmax, mlatmin, xg.x2);
    else
        [E.mlatsig, E.sigx3] = Esigma(p.Efield_latwidth, mlatmax, mlatmin, xg.x3);
    end %if
end
if isfield(p, 'Efield_lonwidth')
    if (flagdip)
        [E.mlonsig, E.sigx3] = Esigma(p.Efield_lonwidth, mlonmax, mlonmin, xg.x3);
    else
        [E.mlonsig, E.sigx2] = Esigma(p.Efield_lonwidth, mlonmax, mlonmin, xg.x2);
    end %if
end
if isfield(p, 'Efield_fracwidth')
  warning('Efield_fracwidth is deprecated. Please use Efield_lonwidth or Efield_latwidth')
  if E.llat ~= 1
      if (flagdip)
          [E.mlatsig, E.sigx2] = Esigma(p.Efield_fracwidth, mlatmax, mlatmin, xg.x2);
      else
          [E.mlatsig, E.sigx3] = Esigma(p.Efield_fracwidth, mlatmax, mlatmin, xg.x3);
      end %if
  end
  if E.llon ~= 1
      if (flagdip)
          [E.mlonsig, E.sigx3] = Esigma(p.Efield_fracwidth, mlonmax, mlonmin, xg.x3);
      else
          [E.mlonsig, E.sigx2] = Esigma(p.Efield_fracwidth, mlonmax, mlonmin, xg.x2);
      end %if
  end
end


%% TIME VARIABLE (SECONDS FROM SIMULATION BEGINNING)
E.times = p.times(1):seconds(p.dtE0):p.times(end);
Nt = length(E.times);


%% CREATE DATA FOR BACKGROUND ELECTRIC FIELDS
if isfield(p, 'Exit')
  E.Exit = p.Exit * ones(E.llon, E.llat, Nt);
else
  E.Exit = zeros(E.llon, E.llat, Nt);
end
if isfield(p, 'Eyit')
  E.Eyit = p.Eyit * ones(E.llon, E.llat, Nt);
else
  E.Eyit = zeros(E.llon, E.llat, Nt);
end


%% CREATE DATA FOR BOUNDARY CONDITIONS FOR POTENTIAL SOLUTION
% if 0 data is interpreted as FAC, else we interpret it as potential
E.flagdirich=zeros(Nt,1);    %in principle can have different boundary types for different time steps...
E.Vminx1it = zeros(E.llon,E.llat, Nt);
E.Vmaxx1it = zeros(E.llon,E.llat, Nt);
%these are just slices
E.Vminx2ist = zeros(E.llat, Nt);
E.Vmaxx2ist = zeros(E.llat, Nt);
E.Vminx3ist = zeros(E.llon, Nt);
E.Vmaxx3ist = zeros(E.llon, Nt);

%% synthesize feature
if isfield(p, 'Etarg')
  E.Etarg = p.Etarg;
  E = Efield_target(E, xg, lx1, lx2, lx3, Nt, gridflag,flagdip);
elseif isfield(p, 'Jtarg')
  E.Jtarg = p.Jtarg;
  E = Jcurrent_target(E, Nt, gridflag);
else
  % background only, pass
end


%% SAVE THESE DATA TO APPROPRIATE FILES
% LEAVE THE SPATIAL AND TEMPORAL INTERPOLATION TO THE
% FORTRAN CODE IN CASE DIFFERENT GRIDS NEED TO BE TRIED.
% THE EFIELD DATA DO NOT TYPICALLY NEED TO BE SMOOTHED.
gemini3d.write.Efield(E, dir_out, p.file_format)

end % function


function E = Jcurrent_target(E, Nt, gridflag)

% Set the top boundary shape (current density) and potential solve type flag

S = E.Jtarg * exp(-(E.MLON - E.mlonmean).^2/2 / E.mlonsig^2) .* exp(-(E.MLAT - E.mlatmean - 1.5 * E.mlatsig).^2/ 2 / E.mlatsig^2);

for i = 6:Nt
  E.flagdirich(i)=0;    %could have different boundary types for different times
  if (gridflag==1)
    E.Vminx1it(:,:,i) = S - E.Jtarg * exp(-(E.MLON - E.mlonmean).^2/ 2 / E.mlonsig^2) .* exp(-(E.MLAT - E.mlatmean + 1.5 * E.mlatsig).^2/ 2 / E.mlatsig^2); 
  else
    E.Vmaxx1it(:,:,i) = S - E.Jtarg * exp(-(E.MLON - E.mlonmean).^2/ 2 / E.mlonsig^2) .* exp(-(E.MLAT - E.mlatmean + 1.5 * E.mlatsig).^2/ 2 / E.mlatsig^2);
  end %if
end

end % function


function E = Efield_target(E, xg, lx1, lx2, lx3, Nt,gridflag,flagdip)

% Set the top boundary shape (potential) and potential solve type flag

%% create feature defined by Efield
% NOTE: h2, h3 have ghost cells, so we use lx1 instead of "end" to index
% pk is a scalar.

if (flagdip)
    if lx3 == 1 % meridional slice
        S = E.Etarg * E.sigx2 .* xg.h2(lx1, floor(lx2/2), 1) .* sqrt(pi)./2;
        taper = erf((E.MLAT - E.mlatmean) / E.mlatsig);
    elseif (lx2>1 & lx3>1)% 3D
        S = E.Etarg * E.sigx2 .* xg.h2(lx1, floor(lx2/2), 1) .* sqrt(pi)./2;
        taper = erf((E.MLON - E.mlonmean) / E.mlonsig) .* erf((E.MLAT - E.mlatmean) / E.mlatsig);
    else
        error(' Efield_target:  you appear to be making a zonal ribbon grid, which is not yet supported');
    end
else
    if lx3 == 1 % east-west
        S = E.Etarg * E.sigx2 .* xg.h2(lx1, floor(lx2/2), 1) .* sqrt(pi)./2;
        taper = erf((E.MLON - E.mlonmean) / E.mlonsig);
    elseif lx2 == 1 % north-south
        S = E.Etarg * E.sigx3 .* xg.h3(lx1, 1, floor(lx3/2)) .* sqrt(pi)./2;
        taper = erf((E.MLAT - E.mlatmean) / E.mlatsig);
    else % 3D
        S = E.Etarg * E.sigx2 .* xg.h2(lx1, floor(lx2/2), 1) .* sqrt(pi)./2;
        taper = erf((E.MLON - E.mlonmean) / E.mlonsig) .* erf((E.MLAT - E.mlatmean) / E.mlatsig);
    end
end %if

% x2ctr = 1/2*(xg.x2(lx2) + xg.x2(1));
for i = 1:Nt
  E.flagdirich(i)=1;
  
  if (gridflag==1)
      E.Vminx1it(:,:,i) = S .* taper;
  else
      E.Vmaxx1it(:,:,i) = S .* taper;
  end %if
end

% for i=1:Nt
%   % When using dirichlet conditions the side walls need to be chosen to be
%   % equipotential with the top corner grid points
%   E.Vminx2it(:,i)=
%   E.Vmaxx2it(:,i)=
%   E.Vminx3it(:,i)=
%   E.Vmaxx3it(:,i)=
% end %for

end % function


function [wsig, xsig] = Esigma(pwidth, pmax, pmin, px)

% Set width given a fraction of the coordinate an extent

wsig = pwidth * (pmax - pmin);
xsig = pwidth * (max(px) - min(px));

end % function
