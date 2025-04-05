  function magcalc(direc, dang, Ltheta, Lphi, alt, xg)
% based on config file, create set of input points for Gemini3D "magcalc" program
% via gemini3d.write.maggrid()
arguments
  direc (1,1) string
  dang (1,1) {mustBeNumeric} = 1.5
  % ANGULAR RANGE TO COVER FOR THE FIELD POINTS - SOURCE POINTS COVER ENTIRE GRID
  Ltheta (1,1) {mustBeInteger, mustBePositive} = 40
  Lphi (1,1) {mustBeInteger, mustBePositive} = 40
  alt (1,1) {mustBeFloat, mustBeFinite} = 0e3
  xg struct = struct.empty
end

gemini3d.sys.check_stdlib()

%% SIMULATION META-DATA
cfg = gemini3d.read.config(direc);

%% LOAD THE GRID FILE
if isempty(xg)
  xg = gemini3d.read.grid(direc);
  disp("Grid loaded: " + xg.filename)
end

flag2D = (xg.lx(3) == 1 || xg.lx(2) == 1);

%% TABULATE THE SOURCE OR GRID CENTER LOCATION

if isempty(cfg.sourcemlon)
  thdist = mean(xg.theta, 'all');
  phidist = mean(xg.phi, 'all');
else
  thdist = pi/2 - deg2rad(cfg.sourcemlat);    %zenith angle of source location
  phidist = deg2rad(cfg.sourcemlon);
end

%% FIELD POINTS OF INTEREST 
% CAN/SHOULD BE DEFINED INDEPENDENT OF SIMULATION GRID
if flag2D
  Lphi=1;
end
lr=1;

thmin=thdist - deg2rad(dang);
thmax=thdist + deg2rad(dang);
phimin=phidist - deg2rad(dang);
phimax=phidist + deg2rad(dang);

theta = linspace(thmin,thmax, Ltheta);
if flag2D
  phi=phidist;
else
  phi=linspace(phimin, phimax, Lphi);
end
r=6370e3*ones(Ltheta, Lphi) + alt;                          %use ground level for altitude for all field points
[phi,theta]=meshgrid(phi,theta);

%% CREATE AN INPUT FILE OF FIELD POINTS
mag.R = r;
mag.PHI = phi;
mag.THETA = theta;
mag.gridsize = [lr, Ltheta, Lphi];

gemini3d.write.maggrid(fullfile(direc, "inputs/magfieldpoints.h5"), mag)

end % function
