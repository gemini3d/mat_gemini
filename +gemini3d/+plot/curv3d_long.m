function curv3d_long(time, xg, parm, parmlbl, caxlims, sourceloc, hf, cmap)
arguments
  time (1,1) datetime
  xg (1,1) struct
  parm (:,:,:) {mustBeNumeric,mustBeNonempty}
  parmlbl (1,1) string = string.empty
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
if ~isempty(sourceloc)
  sourcemlat=sourceloc(1);
  sourcemlon=sourceloc(2);
  flagsource=1;
else
  flagsource=0;
  sourcemlat=[];
  sourcemlon=[];
end

plotparams.sourcemlat = sourcemlat;
plotparams.sourcemlon = sourcemlon;

plotparams.left_xlabel = 'magnetic latitude (deg.)';
plotparams.left_ylabel = 'altitude (km)';

plotparams.mid_ylabel = 'magnetic latitude (deg.)';
plotparams.mid_xlabel = 'magnetic longitude (deg.)';

plotparams.right_xlabel = 'magnetic longitude (deg.)';
plotparams.right_ylabel = 'altitude (km)';
plotparams.sourcemlat = sourcemlat;
plotparams.sourcemlon = sourcemlon;

plotparams.left_xlabel = 'magnetic latitude (deg.)';
plotparams.left_ylabel = 'altitude (km)';

plotparams.mid_ylabel = 'magnetic latitude (deg.)';
plotparams.mid_xlabel = 'magnetic longitude (deg.)';

plotparams.right_xlabel = 'magnetic longitude (deg.)';
plotparams.right_ylabel = 'altitude (km)';
%% SIZE OF SIMULATION
lx1=xg.lx(1); lx2=xg.lx(2); lx3=xg.lx(3);
inds1=3:lx1+2;
inds2=3:lx2+2;
inds3=3:lx3+2;
Re=6370e3;

%% JUST PICK AN X3 LOCATION FOR THE MERIDIONAL SLICE PLOT, AND AN ALTITUDE FOR THE LAT./LON. SLICE
if (size(parm,3)>1)
    ix3=floor(lx3/2);
else
    % ix3=1;
    warning("plot3D_curv_frames_long.m --> only 3D parameters support plotting right now.  Skipping this one...")
    return   % this won't work anyway return for now...
end %if
plotparams.altref=375;

%% SIZE OF PLOT GRID THAT WE ARE INTERPOLATING ONTO
meantheta=mean(xg.theta, 'all');
meanphi=mean(xg.phi, 'all');
x=(xg.theta-meantheta);   %this is a mag colat. coordinate and is only used for defining grid in linspaces below
y=(xg.phi-meanphi);       %mag. lon coordinate
z=xg.alt/1e3;
%lxp=500;
lxp=1500;
lyp=500;
lzp=500;
minx=min(x, [], 'all');
maxx=max(x, [], 'all');
miny=min(y, [], 'all');
maxy=max(y, [], 'all');
%minz=min(z, [], 'all');
minz=-10e0;     %to give some space for the marker on th plots
maxz=max(z, [], 'all');
xp=linspace(minx,maxx,lxp);
yp=linspace(miny,maxy,lyp);
zp=linspace(minz,maxz,lzp)';

%{
%ix1s=floor(lx1/2):lx1;    %only valide for a grid which is symmetric aboutu magnetic equator... (I think)
ix1s=find(xg.x1(inds1)>=0);    %works for asymmetric grids
minz=0;
maxz=max(xg.alt, [], 'all');
[tmp,ix1]=min(abs(xg.alt(ix1s,1,1)-maxz*1e3));
ix1=ix1s(ix1);
thetavals=xg.theta(ix1:lx1,:,:);
meantheta=mean(thetavals, 'all');
phivals=xg.phi(ix1:lx1,:,:);
meanphi=mean(phivals, 'all');
x=(thetavals-meantheta);      %this is a mag colat. coordinate and is only used for defining grid in linspaces below and the parametric surfaces in the plots
y=(phivals-meanphi);          %mag. lon coordinate
z=xg.alt(ix1:lx1,:,:)/1e3;    %altitude
lxp=500;
lyp=500;
lzp=500;
minx=min(x, [], 'all');
maxx=max(x, [], 'all');%+0.5*(max(x, [], 'all')-min(x, [], 'all'));
miny=min(y, [], 'all');
maxy=max(y, [], 'all');
xp=linspace(minx,maxx,lxp);
yp=linspace(miny,maxy,lyp);
zp=linspace(minz,maxz,lzp)';
%}


%INTERPOLATE ONTO PLOTTING GRID
[X,Z]=meshgrid(xp,zp*1e3);    %meridional meshgrid


%DIRECT TO SPHERICAL
rxp=Z(:)+Re;
thetaxp=X(:)+meantheta;
%phixp=Y(:)+meanphi;


%NOW SPHERICAL TO DIPOLE
qplot=(Re./rxp).^2.*cos(thetaxp);
pplot=rxp/Re./sin(thetaxp).^2;
%phiplot=phixp;    %phi is same in spherical and dipole


%-----NOW WE CAN DO A `PLAID' INTERPOLATION - THIS ONE IS FOR THE MERIDIONAL SLICE
parmtmp=parm(:,:,ix3);
parmp=interp2(xg.x2(inds2),xg.x1(inds1),parmtmp,pplot,qplot);
parmp=reshape(parmp,lzp,lxp);    %slice expects the first dim. to be "y" ("z" in the 2D case)


%LAT./LONG. SLICE COORDIANTES
zp2=[290,300,310];
lzp2=3;
[X2,Y2,Z2]=meshgrid(xp,yp,zp2*1e3);       %lat./lon. meshgrid, need 3D since and altitude slice cuts through all 3 dipole dimensions

rxp2=Z2(:)+Re;
thetaxp2=X2(:)+meantheta;
phixp2=Y2(:)+meanphi;

qplot2=(Re./rxp2).^2.*cos(thetaxp2);
pplot2=rxp2/Re./sin(thetaxp2).^2;
phiplot2=phixp2;    %phi is same in spherical and dipole


%-----NOW WE CAN DO A `PLAID' INTERPOLATION - THIS ONE IS FOR THE LAT/LON SLICE
parmtmp=permute(parm,[3,2,1]);
x3interp=xg.x3(inds3);
x3interp=x3interp(:);     %interp doesn't like it unless this is a column vector
parmp2=interp3(xg.x2(inds2),x3interp,xg.x1(inds1),parmtmp,pplot2,phiplot2,qplot2);
parmp2=reshape(parmp2,lyp,lxp,lzp2);    %slice expects the first dim. to be "y"


%ALT./LONG. SLICE COORDIANTES
if (flagsource)
  sourcetheta=pi/2-sourcemlat*pi/180;
else
  thetaref=mean(xg.theta(1:floor(end/2),:,:), 'all');
  sourcetheta=thetaref;
end
sourcex=sourcetheta-meantheta;
xp3=[sourcex-1*pi/180,sourcex,sourcex+1*pi/180];    %place in the plane of the source
lxp3=numel(xp3);
zp3=linspace(minz,750,500);
%minzp3=min(zp3);
%maxzp3=max(zp3);
lzp3=numel(zp3);
[X3,Y3,Z3]=meshgrid(xp3,yp,zp3*1e3);       %lat./lon. meshgrid, need 3D since and altitude slice cuts through all 3 dipole dimensions

rxp3=Z3(:)+Re;
thetaxp3=X3(:)+meantheta;
phixp3=Y3(:)+meanphi;

qplot3=(Re./rxp3).^2.*cos(thetaxp3);
pplot3=rxp3/Re./sin(thetaxp3).^2;
phiplot3=phixp3;    %phi is same in spherical and dipole


%-----NOW WE CAN DO A `PLAID' INTERPOLATION - THIS ONE IS FOR THE LONG/ALT SLICE
%parmtmp=permute(parm,[3,2,1]);
parmp3=interp3(xg.x2(inds2),x3interp,xg.x1(inds1),parmtmp,pplot3,phiplot3,qplot3);
parmp3=reshape(parmp3,lyp,lxp3,lzp3);    %slice expects the first dim. to be "y"


%CONVERT ANGULAR COORDINATES TO MLAT,MLON
xp=90-(xp+meantheta)*180/pi;
[xp,inds]=sort(xp);
parmp=parmp(:,inds);
parmp2=parmp2(:,inds,:);
%parmp3=parmp3(:,inds,:);

yp=(yp+meanphi)*180/pi;
[yp,inds]=sort(yp);
%parmp=parmp(inds,:,:);
parmp2=parmp2(inds,:,:);
parmp3=parmp3(inds,:,:);

%% NOW THAT WE'VE SORTED, WE NEED TO REGENERATE THE MESHGRID
%[XP,YP,ZP]=meshgrid(xp,yp,zp);
% FS=8;

t = tiledlayout(hf, 1, 3);
ax1 = nexttile(t);
ax2 = nexttile(t);
ax3 = nexttile(t);

slice3left(ax1, xp, zp, parmp, plotparams)
slice3mid(ax2, yp, xp, parmp2(:,:,2).', plotparams)
slice3right(ax3, yp, zp3, squeeze(parmp3(:,2,:)).', plotparams)

end % function
