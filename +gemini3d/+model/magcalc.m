function magcalc(direc, dang, xg)
arguments
  direc (1,1) string
  dang (1,1) {mustBeNumeric} = 1.5 % ANGULAR RANGE TO COVER FOR THE CALCLUATIONS (THIS IS FOR THE FIELD POINTS - SOURCE POINTS COVER ENTIRE GRID)
  xg struct = struct.empty
end

direc = gemini3d.fileio.expanduser(direc);
assert(isfolder(direc), direc + " is not a directory")

%SIMULATION META-DATA
cfg = gemini3d.read.config(direc);
assert(~isempty(cfg), direc + " does not contains config.nml")

%WE ALSO NEED TO LOAD THE GRID FILE
if isempty(xg)
  xg = gemini3d.read.grid(direc);
  assert(~isempty(xg), direc + " does not contain simgrid")
%  lx1 = xg.lx(1);
  lx3 = xg.lx(3);
%  lh=lx1;   %possibly obviated in this version - need to check
  if (lx3==1)
    flag2D=true;
    disp('2D meshgrid')
%     x1=xg.x1(3:end-2);
%     x2=xg.x2(3:end-2);
%     x3=xg.x3(3:end-2);
%     [X2,X1]=meshgrid(x2(:),x1(1:lh)');
  else
    flag2D=false;
    disp('3D meshgrid')
%     x1=xg.x1(3:end-2);
%     x2=xg.x2(3:end-2);
%     x3=xg.x3(3:end-2);
%     [X2,X1,X3]=meshgrid(x2(:),x1(1:lh)',x3(:));
  end

  %TABULATE THE SOURCE OR GRID CENTER LOCATION
  if ~isempty(cfg.sourcemlon)
    thdist= pi/2 - deg2rad(cfg.sourcemlat);    %zenith angle of source location
    phidist= deg2rad(cfg.sourcemlon);
  else
    thdist=mean(xg.theta(:));
    phidist=mean(xg.phi(:));
  end
disp('Grid loaded')
end

%FIELD POINTS OF INTEREST (CAN/SHOULD BE DEFINED INDEPENDENT OF SIMULATION GRID)
ltheta=10;
if flag2D
  lphi=1;
else
  lphi=10;
end
%lr=1;

thmin=thdist-dang*pi/180;
thmax=thdist+dang*pi/180;
phimin=phidist-dang*pi/180;
phimax=phidist+dang*pi/180;

theta=linspace(thmin,thmax,ltheta);
if flag2D
  phi=phidist;
else
  phi=linspace(phimin,phimax,lphi);
end
r=6370e3*ones(ltheta,lphi);                          %use ground level for altitude for all field points
[phi,theta]=meshgrid(phi,theta);

%% CREATE AN INPUT FILE OF FIELD POINTS
mag.R = r;
mag.PHI = phi;
mag.THETA = theta;
filename = fullfile(direc, "inputs/magfieldpoints.h5");
gemini3d.write.maggrid(filename, mag)

end % function
