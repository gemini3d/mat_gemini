function Efield_BCs(p, xg)

narginchk(2, 2)
validateattributes(p, {'struct'}, {'scalar'}, mfilename, 'sim parameters', 1)
validateattributes(xg, {'struct'}, {'scalar'})

dir_out = absolute_path(p.E0_dir);
makedir(dir_out);

lx1 = xg.lx(1);
lx2 = xg.lx(2);
lx3 = xg.lx(3);

%% CREATE ELECTRIC FIELD DATASET
E.llon=100;
E.llat=100;
% NOTE: cartesian-specific code
if lx2 == 1
  E.llon = 1;
elseif lx3 == 1
  E.llat = 1;
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
p.mlonmean = mean(E.mlon);
p.mlatmean = mean(E.mlat);

%% WIDTH OF THE DISTURBANCE
p.mlatsig = p.Efield_latwidth*(mlatmax-mlatmin);
p.mlonsig = p.Efield_lonwidth*(mlonmax-mlonmin);

p.sigx2 = p.Efield_lonwidth*(max(xg.x2)-min(xg.x2));
p.sigx3 = p.Efield_latwidth*(max(xg.x3)-min(xg.x3));
%% TIME VARIABLE (SECONDS FROM SIMULATION BEGINNING)
tmin = 0;
time = tmin:p.dtE0:p.tdur;
Nt = length(time);
%% SET UP TIME VARIABLES
UTsec = p.UTsec0 + time;     %time given in file is the seconds from beginning of hour
UThrs = UTsec / 3600;
E.expdate = cat(2, repmat(p.ymd(:)',[Nt, 1]), UThrs', zeros(Nt, 1), zeros(Nt, 1));
% t = datenum(E.expdate);
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
%E.flagdirich=zeros(1,Nt);
E.Vminx1it = zeros(E.llon,E.llat, Nt);
E.Vmaxx1it = zeros(E.llon,E.llat, Nt);
%these are just slices
E.Vminx2ist = zeros(E.llat, Nt);
E.Vmaxx2ist = zeros(E.llat, Nt);
E.Vminx3ist = zeros(E.llon, Nt);
E.Vmaxx3ist = zeros(E.llon, Nt);

%% synthesize feature
if isfield(p, 'Etarg')
  E = Efield_target(p, xg, lx2, lx3, Nt, E);
elseif isfield(p, 'Jtarg')
  E = Jcurrent_target(p, Nt, E);
else
  error('Efield_BCs_3d:lookup_error', 'unknown target feature')
end

%% SAVE THESE DATA TO APPROPRIATE FILES
% LEAVE THE SPATIAL AND TEMPORAL INTERPOLATION TO THE
% FORTRAN CODE IN CASE DIFFERENT GRIDS NEED TO BE TRIED.
% THE EFIELD DATA DO NOT TYPICALLY NEED TO BE SMOOTHED.

write_Efield(p, E, dir_out)

end % function


function E = Jcurrent_target(p, Nt, E)

S = p.Jtarg * exp(-(E.MLON - p.mlonmean).^2/2 / p.mlonsig^2) .* exp(-(E.MLAT - p.mlatmean - 1.5 * p.mlatsig).^2/ 2 / p.mlatsig^2);

for i = 6:Nt
  E.flagdirich(i)=0;    %could have different boundary types for different times
  E.Vmaxx1it(:,:,i) = S - p.Jtarg * exp(-(E.MLON - p.mlonmean).^2/ 2 / p.mlonsig^2) .* exp(-(E.MLAT - p.mlatmean + 1.5 * p.mlatsig).^2/ 2 / p.mlatsig^2);
end

end % function


function E = Efield_target(p, xg, lx2, lx3, Nt, E)
%% create feature defined by Efield
if lx3 == 1 % east-west
  S = p.Etarg * p.sigx2 .* xg.h2(lx1, floor(lx2/2), 1) .* sqrt(pi)./2;
elseif lx2 == 1 % north-south
  S = p.Etarg * p.sigx3 .* xg.h3(lx1, 1, floor(lx3/2)) .* sqrt(pi)./2;
else % 3D
  S = p.Etarg * p.sigx2 .* xg.h2(lx1, floor(lx2/2), 1) .* sqrt(pi)./2;
end

% x2ctr = 1/2*(xg.x2(lx2) + xg.x2(1));
for i = 1:Nt
  E.flagdirich(i)=1;
  E.Vmaxx1it(:,:,i) = S .* erf((E.MLON - p.mlonmean) / p.mlonsig) .* erf((E.MLAT - p.mlatmean) / p.mlatsig);
end

end % function
