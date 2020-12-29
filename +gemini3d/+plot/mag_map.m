function mag_map(direc)
arguments
  direc (1,1) string
end

import gemini3d.fileio.makedir

direc = gemini3d.fileio.expanduser(direc);

addons = matlab.addons.installedAddons();
has_map = any(addons.Name == "Mapping Toolbox");
assert(has_map, "Mapping Toolbox is needed")

%SIMULATIONS LOCAITON
pdir = fullfile(direc, "plots");
makedir(fullfile(pdir, "Br"));
makedir(fullfile(pdir, "Bth"));
makedir(fullfile(pdir, "Bphi"));

basemagdir = fullfile(direc, 'magfields');

%SIMULATION META-DATA
cfg = gemini3d.read.config(direc);

%LOAD/CONSTRUCT THE FIELD POINT GRID

switch cfg.file_format
case 'h5'
  fn = fullfile(direc,'inputs/magfieldpoints.h5');
  assert(isfile(fn), fn + " not found")

  lpoints = h5read(fn, "/lpoints");
  r = h5read(fn, "/r");
  theta = h5read(fn, "/theta");
  phi = h5read(fn, "/phi");
case 'dat'
  fn = fullfile(direc,'inputs/magfieldpoints.dat');
  assert(isfile(fn), fn + " not found")

  fid=fopen(fn, 'r');
  lpoints=fread(fid,1,'integer*4');
  r=fread(fid,lpoints,'real*8');
  theta=fread(fid,lpoints,'real*8');    %by default these are read in as a row vector, AGHHHH!!!!!!!!!
  phi=fread(fid,lpoints,'real*8');
  fclose(fid);
otherwise, error("not sure how to read " + cfg.file_format + " files")
end

%REORGANIZE THE FIELD POINTS (PROBLEM-SPECIFIC)
ltheta=10;
lphi=10;
r=reshape(r(:),[ltheta,lphi]);
theta=reshape(theta(:),[ltheta,lphi]);
phi=reshape(phi(:),[ltheta,lphi]);
mlat=90-theta*180/pi;
[~,ilatsort]=sort(mlat(:,1));    %mlat runs against theta...
mlat=mlat(ilatsort,1);
mlon=phi*180/pi;
[~,ilonsort]=sort(mlon(1,:));
mlon=mlon(1,ilonsort);


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
    fid=fopen(fullfile(basemagdir, filename + ".dat"), 'r');
    data = fread(fid,lpoints,'real*8');
  case 'h5'
    data = h5read(fullfile(direc,'magfields', filename + ".h5"), '/magfields/Br');
  end

  Brt(:,:,:,it)=reshape(data,[1,ltheta,lphi]);
  Brt(:,:,:,it)=Brt(:,ilatsort,:,it);
  Brt(:,:,:,it)=Brt(:,:,ilonsort,it);

  switch cfg.file_format
  case 'dat'
    data = fread(fid,lpoints,'real*8');
  case 'h5'
    data = h5read(fullfile(direc, 'magfields', filename + ".h5"), '/magfields/Btheta');
  end

  Bthetat(:,:,:,it)=reshape(data,[1,ltheta,lphi]);
  Bthetat(:,:,:,it)=Bthetat(:,ilatsort,:,it);
  Bthetat(:,:,:,it)=Bthetat(:,:,ilonsort,it);

  switch cfg.file_format
  case 'dat'
    data=fread(fid,lpoints,'real*8');
  case 'h5'
    data = h5read(fullfile(direc,'magfields', filename + ".h5"), '/magfields/Bphi');
  end

  Bphit(:,:,:,it)=reshape(data,[1,ltheta,lphi]);
  Bphit(:,:,:,it)=Bphit(:,ilatsort,:,it);
  Bphit(:,:,:,it)=Bphit(:,:,ilonsort,it);

  if exist("fid", "var")
    fclose(fid);
  end
end

%STORE THE DATA IN A MATLAB FILE FOR LATER USE
% save([direc,'/magfields_fort.mat'],'times','mlat','mlon','Brt','Bthetat','Bphit');


%INTERPOLATE TO HIGHER SPATIAL RESOLUTION FOR PLOTTING
llonp=200;
llatp=200;
mlonp=linspace(min(mlon(:)),max(mlon(:)),llonp);
mlatp=linspace(min(mlat(:)),max(mlat(:)),llatp);
[MLONP,MLATP]=meshgrid(mlonp,mlatp);
for it=1:length(cfg.times)
  param=interp2(mlon,mlat,squeeze(Brt(:,:,:,it)),MLONP,MLATP);
  Brtp(:,:,:,it)=reshape(param,[1, llonp, llatp]);
  param=interp2(mlon,mlat,squeeze(Bthetat(:,:,:,it)),MLONP,MLATP);
  Bthetatp(:,:,:,it)=reshape(param,[1, llonp, llatp]);
  param=interp2(mlon,mlat,squeeze(Bphit(:,:,:,it)),MLONP,MLATP);
  Bphitp(:,:,:,it)=reshape(param,[1, llonp, llatp]);
end
disp('...Done interpolating')

% mlatsrc=cfg.sourcemlat;
mlonsrc=cfg.sourcemlon;


%TABULATE THE SOURCE OR GRID CENTER LOCATION
if ~isempty(cfg.sourcemlat)
  %thdist= pi/2 - deg2rad(cfg.sourcemlat);    %zenith angle of source location
  %phidist = deg2rad(cfg.sourcemlon);
else
  thdist=mean(theta(:));
  phidist=mean(phi(:));
  cfg.sourcemlat = 90 - rad2deg(thdist);
  cfg.sourcemlon = rad2deg(phidist);
end


%MAKE THE PLOTS AND SAVE TO A FILE
for it=1:length(cfg.times)-1
  %CREATE A MAP AXIS
  figure(1);
  FS=8;

  filename = gemini3d.datelab(cfg.times(it));
  titlestring = datestr(cfg.times(it));

%    subplot(131);
  figure(1)
  clf(1)
  mlatlimplot=[min(mlat)-0.5,max(mlat)+0.5];
  mlonlimplot=[min(mlon)-0.5,max(mlon)+0.5];
  axesm('MapProjection','Mercator','MapLatLimit',mlatlimplot,'MapLonLimit',mlonlimplot);
  param=squeeze(Brtp(:,:,:,it))*1e9;
  mlatlim=[min(mlatp),max(mlatp)];
  mlonlim=[min(mlonp),max(mlonp)];
  [MLAT,MLON]=meshgrat(mlatlim,mlonlim,size(param));
  pcolorm(MLAT,MLON,param);
  %cmap=lbmap(256,'redblue');
  %cmap=flipud(cmap);
  %colormap(cmap);
  colormap(gemini3d.plot.bwr());
  set(gca,'FontSize',FS);
  tightmap;
  caxlim=max(abs(param(:)));
  caxlim=max(caxlim,0.001);
  caxis([-caxlim,caxlim]);
  c=colorbar;
  set(c,'FontSize',FS)
  title(sprintf(['B_r (nT)  ',titlestring,' \n\n']));
  xlabel(sprintf('magnetic long. (deg.) \n\n'))
  ylabel(sprintf('magnetic lat. (deg.)\n\n\n'))
  hold on;
  ax=axis;
  plotm(cfg.sourcemlat, cfg.sourcemlon,'r^','MarkerSize',6,'LineWidth',2);
  hold off;

%    subplot(132);
  figure(2)
  clf(2)
  axesm('MapProjection','Mercator','MapLatLimit',mlatlimplot,'MapLonLimit',mlonlimplot);
  param=squeeze(Bthetatp(:,:,:,it))*1e9;
  pcolorm(MLAT,MLON,param);
%     cmap=lbmap(256,'redblue');
%     cmap=flipud(cmap);
%     colormap(cmap);
  colormap(gemini3d.plot.bwr());
  set(gca,'FontSize',FS);
  tightmap;
  caxlim=max(abs(param(:)));
  caxlim=max(caxlim,0.001);
  caxis([-caxlim,caxlim]);
  c=colorbar;
  set(c,'FontSize',FS)
  title(sprintf(['B_\\theta (nT)  ',titlestring,' \n\n']));
  xlabel(sprintf('magnetic long. (deg.) \n\n'))
  ylabel(sprintf('magnetic lat. (deg.)\n\n\n'))
  hold on;
  ax=axis;
  plotm(cfg.sourcemlat, cfg.sourcemlon,'r^','MarkerSize',6,'LineWidth',2);
  hold off;

%    subplot(133);
  figure(3);
  clf;
  axesm('MapProjection','Mercator','MapLatLimit',mlatlimplot,'MapLonLimit',mlonlimplot);
  param=squeeze(Bphitp(:,:,:,it))*1e9;
  %imagesc(mlon,mlat,param);
  pcolorm(MLAT,MLON,param);
%     cmap=lbmap(256,'redblue');
%     cmap=flipud(cmap);
%     colormap(cmap);
  colormap(gemini3d.plot.bwr());
  set(gca,'FontSize',FS);
  tightmap;
  caxlim=max(abs(param(:)));
  caxlim=max(caxlim,0.001);
  caxis([-caxlim,caxlim]);
  c=colorbar;
  set(c,'FontSize',FS)
  title(sprintf(['B_\\phi (nT)  ',titlestring,' \n\n']));
  xlabel(sprintf('magnetic long. (deg.) \n\n'))
  ylabel(sprintf('magnetic lat. (deg.)\n\n\n'))
  hold on
  ax=axis;
  plotm(cfg.sourcemlat, cfg.sourcemlon, 'r^','MarkerSize',6,'LineWidth',2);
  hold off


  %ADD A MAP OF COASTLINES
  load('coastlines')
  [thetacoast,phicoast] = gemini3d.geog2geomag(coastlat,coastlon);
  mlatcoast=90-thetacoast*180/pi;
  mloncoast=phicoast*180/pi;

  if (360-mlonsrc<20)
    inds=find(mloncoast>180);
    mloncoast(inds)=mloncoast(inds)-360;
  end

%        subplot(131);
  figure(1);
  hold on;
  ax=axis;
  plotm(mlatcoast,mloncoast,'k-','LineWidth',1);
  setm(gca,'MeridianLabel','on','ParallelLabel','on','MLineLocation',2,'PLineLocation',1,'MLabelLocation',2,'PLabelLocation',1);
  gridm on;
  exportgraphics(fullfile(pdir,"Br", filename + ".png"), "resolution", 300)

%        subplot(132);
  figure(2);
  hold on;
  ax=axis;
  plotm(mlatcoast,mloncoast,'k-','LineWidth',1);
  setm(gca,'MeridianLabel','on','ParallelLabel','on','MLineLocation',2,'PLineLocation',1,'MLabelLocation',2,'PLabelLocation',1);
  gridm on;
  exportgraphics(fullfile(pdir,"Bth", filename + ".png"), "resolution", 300)

%        subplot(133);
  figure(3);
  hold on;
  ax=axis;
  plotm(mlatcoast,mloncoast,'k-','LineWidth',1);
  setm(gca,'MeridianLabel','on','ParallelLabel','on','MLineLocation',2,'PLineLocation',1,'MLabelLocation',2,'PLabelLocation',1);
  gridm on;
  exportgraphics(fullfile(pdir,"Bphi", filename + ".png"), "resolution", 300)

  axis(ax);
end % for


end % function
