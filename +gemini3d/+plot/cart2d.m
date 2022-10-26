function cart2d(time,xg,parm,parmlbl,caxlims,sourceloc, h, cmap)

arguments
  time (1,1) datetime
  xg (1,1) struct
  parm (:,:) {mustBeNumeric,mustBeNonempty}
  parmlbl (1,1) string = string.empty
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

%SOURCE LOCATION
if ~isempty(sourceloc)
  sourcemlat=sourceloc(1);
  %sourcemlon=sourceloc(2);
else
  sourcemlat=[];
  %sourcemlon=[];
end


%SIZE OF SIMULATION
lx1=xg.lx(1); lx2=xg.lx(2); lx3=xg.lx(3);
inds1=3:lx1+2;
inds2=3:lx2+2;
inds3=3:lx3+2;
Re=6370e3;


%JUST PICK AN X3 LOCATION FOR THE MERIDIONAL SLICE PLOT, AND AN ALTITUDE FOR THE LAT./LON. SLICE
%ix3=floor(lx3/2);
plotparams.altref=300;


%SIZE OF PLOT GRID THAT WE ARE INTERPOLATING ONTO
meantheta=mean(xg.theta, 'all');
%meanphi=mean(xg.phi, 'all');
y=-1*(xg.theta-meantheta);   %this is a mag colat. coordinate and is only used for defining grid in linspaces below, runs backward from north distance, hence the negative sign
%x=(xg.phi-meanphi);       %mag. lon coordinate, pos. eastward
x=xg.x2(inds2)/Re/sin(meantheta);
z=xg.alt;
lxp=500;
lyp=500;
lzp=500;
minx=min(x, [], 'all');
maxx=max(x, [], 'all');
miny=min(y, [], 'all');
maxy=max(y, [], 'all');
minz=min(z, [], 'all');
maxz=max(z, [], 'all');
xp=linspace(minx,maxx,lxp);     %eastward distance (rads.)
yp=linspace(miny,maxy,lyp);     %should be interpreted as northward distance (in rads.).  Irrespective of ordering of xg.theta, this will be monotonic increasing!!!
zp=linspace(minz,maxz,lzp)';     %altitude (meters)


assert(ismatrix(parm) && ~isscalar(parm), ['need 2-D or 1-D ',parmlbl,' -- is squeeze() needed?  size(parm):', num2str(size(parm))])

%INTERPOLATE ONTO PLOTTING GRID
if xg.lx(3)==1     %alt./lon. slice
  if isvector(parm)
    parmp = interp1(xg.x2(inds2), parm, xp*Re*sin(meantheta));
  elseif ismatrix(parm)
    [X,Z]=meshgrid(xp,zp);    %meridional meshgrid, this defines the grid for plotting
    x1plot=Z(:);   % upward distance (meters)
    x2plot=X(:)*Re*sin(meantheta);     % eastward distance (meters)

    parmtmp=parm(:,:);
    parmp=interp2(xg.x2(inds2),xg.x1(inds1),parmtmp,x2plot,x1plot);
    parmp=reshape(parmp,[lzp,lxp]);    %slice expects the first dim. to be "y" ("z" in the 2D case)
  end
elseif xg.lx(2)==1    %alt./lat. slice
  if isvector(parm)
    parmp = interp1(xg.x3(inds3), parm, yp*Re);
  elseif ismatrix(parm)
    [Y,Z]=meshgrid(yp,zp);

    x1plot = Z(:); % upward distance (meters)
    x3plot = Y(:)*Re; % northward distance (meters)

    %ix2=floor(lx2/2);
    parmtmp=parm(:,:);     %so north dist, east dist., alt.
    parmp=interp2(xg.x3(inds3),xg.x1(inds1),parmtmp,x3plot,x1plot);
    parmp=reshape(parmp,[lzp,lyp]);    %slice expects the first dim. to be "y"
  end
end


%CONVERT ANGULAR COORDINATES TO MLAT,MLON
if (xg.lx(2)==1)
  yp=yp*Re;
  [yp,inds]=sort(yp);
  %parmp2=parmp2(inds,:,:);
  parmp=parmp(:,inds);
elseif (xg.lx(3)==1)
  %xp=(xp+meanphi)*180/pi;
  xp=xp*Re*sin(meantheta);    %eastward ground distance
  [xp,inds]=sort(xp);
  parmp=parmp(:,inds,:);
  %parmp2=parmp2(:,inds,:);
end

%% MAKE THE PLOT
if isvector(parm)
  if xg.lx(3) == 1
    plot1d2(xp, parmp, ha, plotparams)
  elseif xg.lx(2) == 1
    plot1d3(yp, parmp, ha, plotparams)
  end
else
  if xg.lx(3)==1
    plot12(xp, zp, parmp, ha, sourcemlat, plotparams)
  elseif xg.lx(2)==1
    plot13(yp, zp, parmp, ha, sourcemlat, plotparams)
  end
end

title(ha, string(time) + " UT")

end % function

function plot1d2(xp, parm, ha, plotparams)
plot(ha, xp/1e3, parm)
xlabel(ha, 'eastward dist. (km)')
ylabel(ha, plotparams.parmlbl)
end % function


function plot1d3(yp, parm, ha, plotparams)
plot(ha, yp/1e3, parm)
xlabel(ha, 'northward dist. (km)')
ylabel(ha, plotparams.parmlbl)
end % function


function plot12(xp, zp, parmp, ha, sourcemlat, plotparams)
hi = imagesc(xp/1e3, zp/1e3,parmp, 'parent', ha);
hold(ha, 'on')
yline(ha, plotparams.altref,'w--','LineWidth',2)

if ~isempty(sourcemlat)
  plot(ha, sourcemlat,0,'r^','MarkerSize',12,'LineWidth',2)
end
hold(ha, 'off')

set(hi, 'alphadata', ~isnan(parmp))

axes_tidy(ha, plotparams)

xlabel(ha, 'eastward dist. (km)')
ylabel(ha, 'altitude (km)')

end


function plot13(yp, zp, parmp, ha, sourcemlat, plotparams)
hi = imagesc(yp/1e3, zp/1e3, parmp, 'parent', ha);
hold(ha, 'on')
% yline(ha, altref, 'w--','LineWidth',2);
if (~isempty(sourcemlat))
  plot(ha, sourcemlat,0,'r^','MarkerSize',12,'LineWidth',2);
end
hold(ha, 'off')

set(hi, 'alphadata', ~isnan(parmp))

axes_tidy(ha, plotparams)

xlabel(ha, 'northward dist. (km)')
ylabel(ha, 'altitude (km)')

end % function
