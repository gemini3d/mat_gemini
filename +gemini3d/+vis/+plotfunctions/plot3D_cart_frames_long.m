function plot3D_cart_frames_long(time, xg, parm, parmlbl, caxlims, sourceloc, hf, cmap)
arguments
  time (1,1) datetime
  xg (1,1) struct
  parm (:,:,:) {mustBeNumeric,mustBeNonempty}
  parmlbl (1,1) string = ""
  caxlims (1,:) {mustBeNumeric} = []
  sourceloc (1,:) {mustBeNumeric} = []
  hf (1,1) matlab.ui.Figure = figure()
  cmap (:,:) {mustBeNumeric,mustBeFinite} = parula(256)
end

plotparams.time = time;
plotparams.parmlbl = parmlbl;
plotparams.caxlims = caxlims;
plotparams.cmap = cmap;

%% SOURCE LOCATION
if (~isempty(sourceloc))
  sourcemlat=sourceloc(1);
  sourcemlon=sourceloc(2);
else
  sourcemlat=[];
  sourcemlon=[];
end
plotparams.sourcemlat = sourcemlat;
plotparams.sourcemlon = sourcemlon;

plotparams.left_xlabel = 'magnetic longitude (deg.)';
plotparams.left_ylabel = 'altitude (km)';

plotparams.mid_ylabel = 'magnetic latitude (deg.)';
plotparams.mid_xlabel = 'magnetic longitude (deg.)';

plotparams.right_xlabel = 'magnetic latitude (deg.)';
plotparams.right_ylabel = 'altitude (km)';
%% SIZE OF SIMULATION
lx1=xg.lx(1); lx2=xg.lx(2); lx3=xg.lx(3);
inds1=3:lx1+2;
inds2=3:lx2+2;
inds3=3:lx3+2;
Re=6370e3;

%% JUST PICK AN X3 LOCATION FOR THE MERIDIONAL SLICE PLOT, AND AN ALTITUDE FOR THE LAT./LON. SLICE
ix3=floor(lx3/2);
plotparams.altref=110;

%% SIZE OF PLOT GRID THAT WE ARE INTERPOLATING ONTO
meantheta=mean(xg.theta(:));
meanphi=mean(xg.phi(:));
y=-1*(xg.theta-meantheta);   %this is a mag colat. coordinate and is only used for defining grid in linspaces below, runs backward from north distance, hence the negative sign
x=(xg.phi-meanphi);       %mag. lon coordinate, pos. eastward
z=xg.alt/1e3;
lxp=500;
lyp=500;
lzp=500;
minx=min(x(:));
maxx=max(x(:));
miny=min(y(:));
maxy=max(y(:));
minz=min(z(:));
maxz=max(z(:));
xp=linspace(minx,maxx,lxp);     %eastward distance (rads.)
yp=linspace(miny,maxy,lyp);     %should be interpreted as northward distance (in rads.).  Irrespective of ordering of xg.theta, this will be monotonic increasing!!!
zp=linspace(minz,maxz,lzp)';     %altitude (meters)

%{
%ix1s=floor(lx1/2):lx1;    %only valide for a grid which is symmetric aboutu magnetic equator... (I think)
ix1s=find(xg.x1(inds1)>=0);    %works for asymmetric grids
minz=0;
maxz=max(xg.alt(:));
[tmp,ix1]=min(abs(xg.alt(ix1s,1,1)-maxz*1e3));
ix1=ix1s(ix1);
thetavals=xg.theta(ix1:lx1,:,:);
meantheta=mean(thetavals(:));
phivals=xg.phi(ix1:lx1,:,:);
meanphi=mean(phivals(:));
x=(thetavals-meantheta);      %this is a mag colat. coordinate and is only used for defining grid in linspaces below and the parametric surfaces in the plots
y=(phivals-meanphi);          %mag. lon coordinate
z=xg.alt(ix1:lx1,:,:)/1e3;    %altitude
lxp=500;
lyp=500;
lzp=500;
minx=min(x(:));
maxx=max(x(:));%+0.5*(max(x(:))-min(x(:)));
miny=min(y(:));
maxy=max(y(:));
xp=linspace(minx,maxx,lxp);
yp=linspace(miny,maxy,lyp);
zp=linspace(minz,maxz,lzp)';
%}


%INTERPOLATE ONTO PLOTTING GRID
[X,Z]=meshgrid(xp,zp*1e3);    %meridional meshgrid, this defines the grid for plotting


%%DIRECT TO SPHERICAL, CONVERSION FOR THE PLOT GRID
%rxp=Z(:)+Re;
%thetaxp=X(:)+meantheta;
%%phixp=Y(:)+meanphi;


%NOW SPHERICAL TO DIPOLE (OR WHATEVER COORDIANTE SYSTEM X1,X2,X3 IN THE SIMULATION WAS)
%qplot=(Re./rxp).^2.*cos(thetaxp);
%pplot=rxp/Re./sin(thetaxp).^2;
%%%phiplot=phixp;    %phi is same in spherical and dipole


%%NOW WE CAN DO A `PLAID' INTERPOLATION - THIS ONE IS FOR THE MERIDIONAL SLICE
%parmtmp=parm(:,:,ix3);
%parmp=interp2(xg.x2(inds2),xg.x1(inds1),parmtmp,pplot,qplot);
%parmp=reshape(parmp,lzp,lxp);    %slice expects the first dim. to be "y" ("z" in the 2D case)


%% CONVERT TO DISTANCE UP, EAST, NORTH
x1plot=Z(:);   %upward distance
x2plot=X(:)*Re*sin(meantheta);     %eastward distance

parmtmp=parm(:,:,ix3);
parmp=interp2(xg.x2(inds2),xg.x1(inds1),parmtmp,x2plot,x1plot);
parmp=reshape(parmp,[lzp,lxp]);    %slice expects the first dim. to be "y" ("z" in the 2D case)

%% LAT./LONG. SLICE COORDINATES
%zp2=[290,300,310];
zp2=[altref-10,altref,altref+10];
lzp2=numel(zp2);
[X2,Y2,Z2]=meshgrid(xp,yp,zp2*1e3);       %lat./lon. meshgrid, need 3D since and altitude slice cuts through all 3 dipole dimensions

%rxp2=Z2(:)+Re;
%thetaxp2=X2(:)+meantheta;
%phixp2=Y2(:)+meanphi;
%
%qplot2=(Re./rxp2).^2.*cos(thetaxp2);
%pplot2=rxp2/Re./sin(thetaxp2).^2;
%phiplot2=phixp2;    %phi is same in spherical and dipole
%
%% NOW WE CAN DO A `PLAID' INTERPOLATION - THIS ONE IS FOR THE LAT/LON SLICE
%parmtmp=permute(parm,[3,2,1]);
%x3interp=xg.x3(inds3);
%x3interp=x3interp(:);     %interp doesn't like it unless this is a column vector
%parmp2=interp3(xg.x2(inds2),x3interp,xg.x1(inds1),parmtmp,pplot2,phiplot2,qplot2);
%parmp2=reshape(parmp2,lyp,lxp,lzp2);    %slice expects the first dim. to be "y"

x1plot=Z2(:);   %upward distance
x2plot=X2(:)*Re*sin(meantheta);     %eastward distance - needs to be fixed to be theta-dependent (e.g. sin theta)
x3plot=Y2(:)*Re;     %northward distance;

parmtmp=permute(parm,[3,2,1]);     %so north dist, east dist., alt.
x3interp=xg.x3(inds3);  %this is northward distance - again backwards from yp
x3interp=x3interp(:);     %interp doesn't like it unless this is a column vector
parmp2=interp3(xg.x2(inds2),x3interp,xg.x1(inds1),parmtmp,x2plot,x3plot,x1plot);
parmp2=reshape(parmp2,[lyp,lxp,lzp2]);    %slice expects the first dim. to be "y"


%ALT/LAT SLICE
[Y3,Z3]=meshgrid(yp,zp*1e3);

x1plot=Z3(:);   %upward distance
x3plot=Y3(:)*Re;     %northward distance;

ix2=floor(lx2/2);
parmtmp=squeeze(parm(:,ix2,:));     %so north dist, east dist., alt.

parmp3=interp2(xg.x3(inds3),xg.x1(inds1),parmtmp,x3plot,x1plot);
parmp3=reshape(parmp3,[lzp,lyp]);    %slice expects the first dim. to be "y"


%CONVERT ANGULAR COORDINATES TO MLAT,MLON
%yp=90-(yp+meantheta)*180/pi;     %convert northward distance (in rads.) to magnetic latitude
yp=(yp+(pi/2-meantheta))*180/pi;
[yp,inds]=sort(yp);
%parmp=parmp(inds,:);

%This is immensely confusing...  The interpolated parameters are sorted according to northward distance so they don't need to be shuffled wrt mlat???
parmp2=parmp2(inds,:,:);
parmp3=parmp3(:,inds);

xp=(xp+meanphi)*180/pi;
[xp,inds]=sort(xp);
parmp=parmp(:,inds,:);
parmp2=parmp2(:,inds,:);

%NOW THAT WE'VE SORTED, WE NEED TO REGENERATE THE MESHGRID
%[XP,YP,ZP]=meshgrid(xp,yp,zp);
% FS=12;


if verLessThan('matlab', '9.7')
  ax1 = subplot(1,3,1, 'parent', hf, 'nextplot', 'add'); %, 'FontSize', FS);
  ax2 = subplot(1,3,2, 'parent', hf, 'nextplot', 'add'); %, 'FontSize', FS);
  ax3 = subplot(1,3,3, 'parent', hf, 'nextplot', 'add'); %, 'FontSize', FS);
else
  t = tiledlayout(hf, 1, 3);
  ax1 = nexttile(t);
  ax2 = nexttile(t);
  ax3 = nexttile(t);
end

gemini3d.vis.plotfunctions.slice3left(ax1, xp, zp, parmp, plotparams)

gemini3d.vis.plotfunctions.slice3mid(ax2, xp, yp, parmp2(:,:,2), plotparams)

gemini3d.vis.plotfunctions.slice3right(ax3, yp, zp, parmp3, plotparams)

end
