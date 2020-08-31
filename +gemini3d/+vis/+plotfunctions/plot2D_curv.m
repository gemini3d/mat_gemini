function plot2D_curv(time,xg,parm,parmlbl,caxlims, sourceloc, h, cmap)
arguments
  time (1,1) datetime
  xg (1,1) struct
  parm (:,:,:) {mustBeNumeric,mustBeNonempty}
  parmlbl (1,1) string = ""
  caxlims (1,:) {mustBeNumeric} = []
  sourceloc (1,:) {mustBeNumeric} = []
  h (1,1) = []
  cmap (:,:) {mustBeNumeric,mustBeFinite} = parula(256)
end

plotparams.time = time;
plotparams.parmlbl = parmlbl;
plotparams.caxlims = caxlims;
plotparams.cmap = cmap;

if isa(h, 'matlab.ui.Figure')
  ha = axes('parent', h);
elseif isa(h, 'matlab.graphics.axis.Axes')
  ha = h;
end

%SOURCE LOCATION (SHOULD PROBABLY BE AN INPUT)
sourcemlat=sourceloc(1);
%sourcemlon=sourceloc(2);


%SIZE OF SIMULATION
lx1=xg.lx(1); lx2=xg.lx(2); %lx3=xg.lx(3);
inds1=3:lx1+2;
inds2=3:lx2+2;
%inds3=3:lx3+2;
Re=6370e3;


%JUST PICK AN X3 LOCATION FOR THE MERIDIONAL SLICE PLOT, AND AN ALTITUDE FOR THE LAT./LON. SLICE
%ix3=floor(lx3/2);
ix3=1;
altref=300;


%SIZE OF PLOT GRID THAT WE ARE INTERPOLATING ONTO
meantheta=mean(xg.theta(:));
%meanphi=mean(xg.phi(:));
%meanphi=xg.x3(inds3(1));     %dont' forget that x3 has ghost cells!!!
x=(xg.theta-meantheta);   %this is a mag colat. coordinate and is only used for defining grid in linspaces below
%y=(xg.phi-meanphi);       %mag. lon coordinate
z=xg.alt/1e3;
lxp=1500;
%lyp=500;
lzp=1500;
minx=min(x(:));
maxx=max(x(:));
%miny=min(y(:));
%maxy=max(y(:));
%minz=min(z(:));
minz=0;
maxz=max(z(:));
xp=linspace(minx,maxx,lxp);
%yp=linspace(miny,maxy,lyp);
zp=linspace(minz,maxz,lzp)';

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
[X,Z]=meshgrid(xp,zp*1e3);    %meridional meshgrid


%DIRECT TO SPHERICAL
rxp=Z(:)+Re;
thetaxp=X(:)+meantheta;
%phixp=Y(:)+meanphi;


%NOW SPHERICAL TO DIPOLE
qplot=(Re./rxp).^2.*cos(thetaxp);
pplot=rxp/Re./sin(thetaxp).^2;
%phiplot=phixp;    %phi is same in spherical and dipole


%NOW WE CAN DO A `PLAID' INTERPOLATION - THIS ONE IS FOR THE MERIDIONAL SLICE
parmtmp=parm(:,:,ix3);
parmp=interp2(xg.x2(inds2),xg.x1(inds1),parmtmp,pplot,qplot);
parmp=reshape(parmp,lzp,lxp);    %slice expects the first dim. to be "y" ("z" in the 2D case)


%{
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


%NOW WE CAN DO A `PLAID' INTERPOLATION - THIS ONE IS FOR THE LAT/LON SLICE
parmtmp=permute(parm,[3,2,1]);
x3interp=xg.x3(inds3);
x3interp=x3interp(:);     %interp doesn't like it unless this is a column vector
parmp2=interp3(xg.x2(inds2),x3interp,xg.x1(inds1),parmtmp,pplot2,phiplot2,qplot2);
parmp2=reshape(parmp2,lyp,lxp,lzp2);    %slice expects the first dim. to be "y"
%}

%CONVERT ANGULAR COORDINATES TO MLAT,MLON
xp=90-(xp+meantheta)*180/pi;
[xp,inds]=sort(xp);
parmp=parmp(:,inds);
%parmp2=parmp2(:,inds,:);

%{
yp=(yp+meanphi)*180/pi;
[yp,inds]=sort(yp);
parmp=parmp(inds,:,:);
%parmp2=parmp2(inds,:,:);
%}

%NOW THAT WE'VE SORTED, WE NEED TO REGENERATE THE MESHGRID
%[XP,YP,ZP]=meshgrid(xp,yp,zp);
%FS=12;

%MAKE THE PLOT!
%subplot(121);
hi=imagesc(ha,xp,zp,parmp);
hold(ha,'on')
yline(ha, altref,'w--','LineWidth',2);
plot(ha,sourcemlat,0,'r^','MarkerSize',8,'LineWidth',2);
hold(ha,'off')
set(hi,'alphadata',~isnan(parmp))

gemini3d.vis.plotfunctions.axes_tidy(ha, plotparams)
xlabel(ha,'magnetic latitude (deg.)')
ylabel(ha,'altitude (km)')


%{
subplot(122);
hi=imagesc(xp,yp,parmp2(:,:,2));
hold on;
yline(sourcemlon,'w--','LineWidth',2);
plot(sourcemlat,sourcemlon,'r^','MarkerSize',12,'LineWidth',2);
hold off;
set(hi,'alphadata',~isnan(parmp2(:,:,2)));

gemini3d.vis.plotfunctions.axes_tidy(gca, plotparams)
xlabel('magnetic latitude (deg.)')
ylabel('magnetic longitude (deg.)')
%}

title(ha, [datestr(time), ' UT'])

end % function
