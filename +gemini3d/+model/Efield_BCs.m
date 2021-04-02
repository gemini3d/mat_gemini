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
  % inverted
  gridflag=1;
  disp(" Efield_BCs:  Detected an inverted grid...");
else
  % non-inverted or closed
  gridflag=2;
  disp(" Efield_BCs:  Detected a non-inverted grid...");
end

%% determine what type of grid (cartesian or dipole) we are dealing with
if (any(xg.h1>1.01))
  flagdip=true;
  disp(' Efield_BCs:  Dipole grid detected...');
else
  flagdip=false;
  disp(' Efield_BCs:  Cartesian grid detected...');
end


%% number of points for input data
if isfield(p, "Efield_llon")
  E.llon = p.Efield_llon;
else
  E.llon=100;
end

if isfield(p, "Efield_llat")
  E.llat = p.Efield_llat;
else
  E.llat = 100;
end

if flagdip
  if lx3 == 1
    E.llon=1;
  elseif lx2==1
    E.llat=1;
  end
else
  if lx2 == 1
    E.llon = 1;
  elseif lx3 == 1
    E.llat = 1;
  end
end

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
  if flagdip
    [E.mlatsig, E.sigx2] = Esigma(p.Efield_latwidth, mlatmax, mlatmin, xg.x2);
  else
    [E.mlatsig, E.sigx3] = Esigma(p.Efield_latwidth, mlatmax, mlatmin, xg.x3);
  end
end
if isfield(p, 'Efield_lonwidth')
  if flagdip
    [E.mlonsig, E.sigx3] = Esigma(p.Efield_lonwidth, mlonmax, mlonmin, xg.x3);
  else
    [E.mlonsig, E.sigx2] = Esigma(p.Efield_lonwidth, mlonmax, mlonmin, xg.x2);
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

  if isfield(p, "Etarg_function")
    func = str2func(p.Etarg_function);
  else
    func = str2func("gemini3d.model.Etarg_erf");
  end

  E = func(E, xg, lx1, lx2, lx3, Nt, gridflag,flagdip);

elseif isfield(p, 'Jtarg')
  E.Jtarg = p.Jtarg;

  if isfield(p, "Jtarg_function")
    func = str2func(p.Jtarg_function);
  else
    func = str2func("gemini3d.model.Jcurrent_gaussian");
  end

  E = func(E, Nt, gridflag, flagdip);

else
  % background only, pass
end


%% SAVE THESE DATA TO APPROPRIATE FILES
% LEAVE THE SPATIAL AND TEMPORAL INTERPOLATION TO THE
% FORTRAN CODE IN CASE DIFFERENT GRIDS NEED TO BE TRIED.
% THE EFIELD DATA DO NOT TYPICALLY NEED TO BE SMOOTHED.
gemini3d.write.Efield(E, dir_out, p.file_format)

end % function


function [wsig, xsig] = Esigma(pwidth, pmax, pmin, px)

% Set width given a fraction of the coordinate an extent

wsig = pwidth * (pmax - pmin);
xsig = pwidth * (max(px) - min(px));

end % function
