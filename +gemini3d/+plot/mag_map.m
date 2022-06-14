function mag_map(direc)
arguments
  direc (1,1) string
end

import stdlib.fileio.expanduser
import stdlib.fileio.makedir

addons = matlab.addons.installedAddons();
assert(any(addons.Name == "Mapping Toolbox"), "Mapping Toolbox is needed")

freal = 'float64';

direc = expanduser(direc);

%SIMULATIONS LOCAITON
pdir = fullfile(direc, "plots");
makedir(pdir)
basemagdir = fullfile(direc, 'magfields');

%SIMULATION META-DATA
cfg = gemini3d.read.config(direc);

%LOAD/CONSTRUCT THE FIELD POINT GRID

fn = fullfile(direc, "inputs/magfieldpoints." + cfg.file_format);
assert(isfile(fn), fn + " not found")

switch cfg.file_format
case 'h5'
  lpoints = h5read(fn, "/lpoints");
  % r = h5read(fn, "/r");
  theta = double(h5read(fn, "/theta"));
  phi = double(h5read(fn, "/phi"));
case 'dat'
  fid=fopen(fn, 'r');
  lpoints=fread(fid,1,'integer*4');
  fread(fid,lpoints, freal);
  theta=fread(fid,lpoints, freal);    %by default these are read in as a row vector, AGHHHH!!!!!!!!!
  phi=fread(fid,lpoints, freal);
  fclose(fid);
otherwise, error("not sure how to read " + cfg.file_format + " files")
end

%REORGANIZE THE FIELD POINTS (PROBLEM-SPECIFIC)
ltheta=10;
lphi=10;
%r=reshape(r(:),[ltheta,lphi]);
theta=reshape(theta(:),[ltheta,lphi]);
phi=reshape(phi(:),[ltheta,lphi]);
mlat=90-theta*180/pi;
[~,ilatsort]=sort(mlat(:,1));    %mlat runs against theta...
cfg.mlat=mlat(ilatsort,1);
mlon=phi*180/pi;
[~,ilonsort]=sort(mlon(1,:));
cfg.mlon=mlon(1,ilonsort);


%THESE DATA ARE ALMOST CERTAINLY NOT LARGE SO LOAD THEM ALL AT ONCE (CAN
%CHANGE THIS LATER).
% NOTE THAT THE DATA NEED TO BE SORTED BY MLAT,MLON AS WE GO
Brt=zeros(1,ltheta,lphi, length(cfg.times));
Bthetat=zeros(1,ltheta,lphi, length(cfg.times));
Bphit=zeros(1,ltheta,lphi, length(cfg.times));

for it=2:length(cfg.times)-1    %starts at second time step due to weird magcalc quirk
  filename = gemini3d.datelab(cfg.times(it));

  switch cfg.file_format
  case 'dat'
    fid = fopen(fullfile(basemagdir, filename + ".dat"), 'r');
    data = fread(fid,lpoints, freal);
  case 'h5', data = h5read(fullfile(direc,'magfields', filename + ".h5"), '/magfields/Br');
  end

  Brt(:,:,:,it)=reshape(data,[1,ltheta,lphi]);
  Brt(:,:,:,it)=Brt(:,ilatsort,:,it);
  Brt(:,:,:,it)=Brt(:,:,ilonsort,it);

  switch cfg.file_format
  case 'dat', data = fread(fid,lpoints, freal);
  case 'h5', data = h5read(fullfile(direc, 'magfields', filename + ".h5"), '/magfields/Btheta');
  end

  Bthetat(:,:,:,it)=reshape(data,[1,ltheta,lphi]);
  Bthetat(:,:,:,it)=Bthetat(:,ilatsort,:,it);
  Bthetat(:,:,:,it)=Bthetat(:,:,ilonsort,it);

  switch cfg.file_format
  case 'dat', data=fread(fid,lpoints, freal);
  case 'h5', data = h5read(fullfile(direc,'magfields', filename + ".h5"), '/magfields/Bphi');
  end

  Bphit(:,:,:,it)=reshape(data,[1,ltheta,lphi]);
  Bphit(:,:,:,it)=Bphit(:,ilatsort,:,it);
  Bphit(:,:,:,it)=Bphit(:,:,ilonsort,it);

  if exist("fid", "var")
    fclose(fid);
  end
end

%INTERPOLATE TO HIGHER SPATIAL RESOLUTION FOR PLOTTING
llonp=200;
llatp=200;
mlonp=linspace(min(mlon(:)),max(mlon(:)),llonp);
mlatp=linspace(min(mlat(:)),max(mlat(:)),llatp);
[MLONP,MLATP]=meshgrid(mlonp,mlatp);
for it=1:length(cfg.times)
  param=interp2(cfg.mlon, cfg.mlat,squeeze(Brt(:,:,:,it)),MLONP,MLATP);
  Brtp(:,:,:,it)=reshape(param,[1, llonp, llatp]);
  param=interp2(cfg.mlon, cfg.mlat,squeeze(Bthetat(:,:,:,it)),MLONP,MLATP);
  Bthetatp(:,:,:,it)=reshape(param,[1, llonp, llatp]);
  param=interp2(cfg.mlon, cfg.mlat,squeeze(Bphit(:,:,:,it)),MLONP,MLATP);
  Bphitp(:,:,:,it)=reshape(param,[1, llonp, llatp]);
end
disp('...Done interpolating')

% mlatsrc=cfg.sourcemlat;
mlonsrc=cfg.sourcemlon;


%TABULATE THE SOURCE OR GRID CENTER LOCATION
if isempty(cfg.sourcemlat)
  thdist=mean(theta(:));
  phidist=mean(phi(:));
  cfg.sourcemlat = 90 - rad2deg(thdist);
  cfg.sourcemlon = rad2deg(phidist);
else
  %thdist= pi/2 - deg2rad(cfg.sourcemlat);    %zenith angle of source location
  %phidist = deg2rad(cfg.sourcemlon);
end


%MAKE THE PLOTS AND SAVE TO A FILE

coast = load('coastlines', 'coastlat', 'coastlon');
[thetacoast,phicoast] = gemini3d.geog2geomag(coast.coastlat, coast.coastlon);
cfg.mlatcoast=90-thetacoast*180/pi;
cfg.mloncoast=phicoast*180/pi;

if 360-mlonsrc < 20
  i = cfg.mloncoast > 180;
  cfg.mloncoast(i) = cfg.mloncoast(i)-360;
end

mlatlim=[min(mlatp),max(mlatp)];
mlonlim=[min(mlonp),max(mlonp)];
[cfg.MLAT, cfg.MLON]=meshgrat(mlatlim,mlonlim,[llonp, llatp]); %#ok<MESHGRAT>

fig = figure('position', [10, 10, 1200, 500]);

for it=1:length(cfg.times)-1
  filename = gemini3d.datelab(cfg.times(it));
  ttxt = string(cfg.times(it));

  clf(fig)
  subplot(1,3,1, 'parent', fig)
  plotBr(Brtp(:,:,:,it), cfg, ttxt);
  subplot(1,3,2, 'parent', fig)
  plotBtheta(Bthetatp(:,:,:,it), cfg, ttxt);
  subplot(1,3,3, 'parent', fig)
  plotBphi(Bphitp(:,:,:,it), cfg, ttxt);

  pfn = fullfile(pdir, "B-" + filename + ".png");
  disp("write: " + pfn)
  exportgraphics(fig, pfn, "resolution", 300)

end % for

end % function


function plotBr(Brtp, cfg, ttxt)

ax=axesm('MapProjection','Mercator','MapLatLimit',[min(cfg.mlat)-0.5, max(cfg.mlat)+0.5],'MapLonLimit',[min(cfg.mlon)-0.5,max(cfg.mlon)+0.5]);
param=squeeze(Brtp)*1e9;

pcolorm(cfg.MLAT, cfg.MLON, param, "parent", ax)

colormap(ax, gemini3d.plot.bwr());
% set(ax,'FontSize',FS)
tightmap
caxlim=max(abs(param(:)));
caxlim=max(caxlim,0.001);
clim(ax, [-caxlim,caxlim]);
colorbar("peer", ax)
title(ax, "B_r (nT)  " + ttxt + sprintf('\n\n'))
xlabel(ax, 'magnetic long. (deg.)')
ylabel(ax, sprintf('magnetic lat. (deg.)\n\n'))

plotm(cfg.sourcemlat, cfg.sourcemlon, 'r^','MarkerSize',6,'LineWidth',2, "parent", ax)

%ADD A MAP OF COASTLINES

plotm(cfg.mlatcoast, cfg.mloncoast,'k-','LineWidth',1, "parent", ax)
setm(ax,'MeridianLabel','on','ParallelLabel','on','MLineLocation',2,'PLineLocation',1,'MLabelLocation',2,'PLabelLocation',1);
gridm('on')

end % function


function plotBtheta(Bthetatp, cfg, ttxt)

ax=axesm('MapProjection','Mercator','MapLatLimit',[min(cfg.mlat)-0.5,max(cfg.mlat)+0.5],'MapLonLimit',[min(cfg.mlon)-0.5,max(cfg.mlon)+0.5]);
param=squeeze(Bthetatp)*1e9;
pcolorm(cfg.MLAT, cfg.MLON, param, "parent", ax)
%     cmap=lbmap(256,'redblue');
%     cmap=flipud(cmap);
%     colormap(cmap);
colormap(ax, gemini3d.plot.bwr())
%set(ax,'FontSize',FS)
tightmap
caxlim=max(abs(param(:)));
caxlim=max(caxlim,0.001);
clim(ax, [-caxlim,caxlim])
colorbar("peer", ax)
title(ax, "B_\theta (nT)  " + ttxt + sprintf('\n\n'))
xlabel(ax, 'magnetic long. (deg.)')
ylabel(ax, sprintf('magnetic lat. (deg.)\n\n'))

plotm(cfg.sourcemlat, cfg.sourcemlon,'r^','MarkerSize',6,'LineWidth',2, "parent", ax)

plotm(cfg.mlatcoast, cfg.mloncoast,'k-','LineWidth',1, "parent", ax)
setm(ax,'MeridianLabel','on','ParallelLabel','on','MLineLocation',2,'PLineLocation',1,'MLabelLocation',2,'PLabelLocation',1);
gridm("on")

end % function


function plotBphi(Bphitp, cfg, ttxt)

ax=axesm('MapProjection','Mercator','MapLatLimit',[min(cfg.mlat)-0.5,max(cfg.mlat)+0.5],'MapLonLimit',[min(cfg.mlon)-0.5,max(cfg.mlon)+0.5]);
param=squeeze(Bphitp)*1e9;
%imagesc(mlon,mlat,param);
pcolorm(cfg.MLAT, cfg.MLON, param, "parent", ax)
%     cmap=lbmap(256,'redblue');
%     cmap=flipud(cmap);
%     colormap(cmap);
colormap(ax, gemini3d.plot.bwr())
%set(ax,'FontSize',FS)
tightmap
caxlim=max(abs(param(:)));
caxlim=max(caxlim,0.001);
clim(ax, [-caxlim,caxlim])

colorbar("peer", ax)
title(ax, "B_\phi (nT)  " + ttxt + sprintf('\n\n'));
xlabel(ax, 'magnetic long. (deg.)')
ylabel(ax, sprintf('magnetic lat. (deg.)\n\n'))

plotm(cfg.sourcemlat, cfg.sourcemlon, 'r^','MarkerSize',6,'LineWidth',2, "parent", ax)

plotm(cfg.mlatcoast, cfg.mloncoast,'k-','LineWidth',1, "parent", ax)
setm(ax,'MeridianLabel','on','ParallelLabel','on','MLineLocation',2,'PLineLocation',1,'MLabelLocation',2,'PLabelLocation',1);
gridm("on")

end % function
