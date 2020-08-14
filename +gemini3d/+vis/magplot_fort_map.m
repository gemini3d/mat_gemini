import gemini3d.*

%SIMULATIONS LOCAITONS
%simname='tohoku20113D_highres_var/';
%simname='test3d_fang_mag/';
simname='mooreOK3D_hemis_medres/'
%simname='iowa3D_hemis_medres2/'
%simname='iowa3D_hemis_medres2_control/'
basedir='~/simulations/'
direc=[basedir,simname];
makedir([direc, '/Brplots'])
makedir([direc, '/Brplots_eps'])
makedir([direc, '/Bthplots'])
makedir([direc, '/Bthplots_eps'])
makedir([direc, '/Bphiplots'])
makedir([direc, '/Bphiplots_eps'])

%SIMULATION META-DATA
cfg = read_config(direc);

lt=numel(cfg.times);


%LOAD/CONSTRUCT THE FIELD POINT GRID
basemagdir= fullfile(direc,'magfields.ground.20deg.highres/');
fid=fopen(fullfile(basemagdir,'input/magfieldpoints.dat'),'r');    %needs some way to know what the input file is, maybe force fortran code to use this filename...
lpoints=fread(fid,1,'integer*4');
r=fread(fid,lpoints,'real*8');
theta=fread(fid,lpoints,'real*8');    %by default these are read in as a row vector, AGHHHH!!!!!!!!!
phi=fread(fid,lpoints,'real*8');
fclose(fid);


%REORGANIZE THE FIELD POINTS (PROBLEM-SPECIFIC)
%ltheta=10;
%lphi=10;
%ltheta=192;
%lphi=192;
ltheta=40;
lphi=40;
%ltheta=1600;
%lphi=1;
r=reshape(r(:),[ltheta,lphi]);
theta=reshape(theta(:),[ltheta,lphi]);
phi=reshape(phi(:),[ltheta,lphi]);
mlat=90-theta*180/pi;
[tmp,ilatsort]=sort(mlat(:,1));    %mlat runs against theta...
mlat=mlat(ilatsort,1);
mlon=phi*180/pi;
[tmp,ilonsort]=sort(mlon(1,:));
mlon=mlon(1,ilonsort);


%THESE DATA ARE ALMOST CERTAINLY NOT LARGE SO LOAD THEM ALL AT ONCE (CAN
%CHANGE THIS LATER).  NOTE THAT THE DATA NEED TO BE SORTED BY MLAT,MLON AS
%WE GO
Brt=zeros(1,ltheta,lphi,lt);
Bthetat=zeros(1,ltheta,lphi,lt);
Bphit=zeros(1,ltheta,lphi,lt);

for it=1:lt-1

  filename=datelab(cfg.times(it));
  fid=fopen([basemagdir,filename,'.dat'],'r');

  data=fread(fid,lpoints,'real*8');
  Brt(:,:,:,it)=reshape(data,[1,ltheta,lphi]);
  Brt(:,:,:,it)=Brt(:,ilatsort,:,it);
  Brt(:,:,:,it)=Brt(:,:,ilonsort,it);
  data=fread(fid,lpoints,'real*8');
  Bthetat(:,:,:,it)=reshape(data,[1,ltheta,lphi]);
  Bthetat(:,:,:,it)=Bthetat(:,ilatsort,:,it);
  Bthetat(:,:,:,it)=Bthetat(:,:,ilonsort,it);
  data=fread(fid,lpoints,'real*8');
  Bphit(:,:,:,it)=reshape(data,[1,ltheta,lphi]);
  Bphit(:,:,:,it)=Bphit(:,ilatsort,:,it);
  Bphit(:,:,:,it)=Bphit(:,:,ilonsort,it);

  fclose(fid);
end
fprintf('...Done reading data...\n');


%STORE THE DATA IN A MATLAB FILE FOR LATER USE
save([direc,'/magfields_fort.mat'],'simdate_series','mlat','mlon','Brt','Bthetat','Bphit';


%INTERPOLATE TO HIGHER SPATIAL RESOLUTION FOR PLOTTING
llonp=200;
llatp=200;
mlonp=linspace(min(mlon(:)),max(mlon(:)),llonp);
mlatp=linspace(min(mlat(:)),max(mlat(:)),llatp);
[MLONP,MLATP]=meshgrid(mlonp,mlatp);
for it=1:lt
    param=interp2(mlon,mlat,squeeze(Brt(:,:,:,it)),MLONP,MLATP);
    Brtp(:,:,:,it)=reshape(param,[1, llonp, llatp]);
    param=interp2(mlon,mlat,squeeze(Bthetat(:,:,:,it)),MLONP,MLATP);
    Bthetatp(:,:,:,it)=reshape(param,[1, llonp, llatp]);
    param=interp2(mlon,mlat,squeeze(Bphit(:,:,:,it)),MLONP,MLATP);
    Bphitp(:,:,:,it)=reshape(param,[1, llonp, llatp]);
end
fprintf('...Done interpolating...\n');


%SIMULATION META-DATA
cfg = read_config(direc);


%TABULATE THE SOURCE OR GRID CENTER LOCATION
if ~isempty(cfg.sourcemlat)
  thdist= pi/2 - deg2rad(cfg.sourcemlat);    %zenith angle of source location
  phidist = deg2rad(cfg.sourcemlon);
else
  thdist=mean(theta(:));
  phidist=mean(phi(:));
  cfg.sourcemlat = 90 - rad2deg(thdist);
  cfg.sourcemlon = rad2deg(phidist);
end


%MAKE THE PLOTS AND SAVE TO A FILE
for it=1:lt-1
    fprintf('Printing magnetic field plots...\n');
    %CREATE A MAP AXIS
    figure(1);
    FS=8;

    filename = datelab(cfg.times(it));
    titlestring = datestr(cfg.times(it));

%    subplot(131);
    figure(1);
    clf;
    mlatlimplot=[min(mlat)-0.5,max(mlat)+0.5];
    mlonlimplot=[min(mlon)-0.5,max(mlon)+0.5];
    axesm('MapProjection','Mercator','MapLatLimit',mlatlimplot,'MapLonLimit',mlonlimplot);
    param=squeeze(Brtp(:,:,:,it))*1e9;
    mlatlim=[min(mlatp),max(mlatp)];
    mlonlim=[min(mlonp),max(mlonp)];
    [MLAT,MLON]=meshgrat(mlatlim,mlonlim,size(param));
    pcolorm(MLAT,MLON,param);
    cmap=lbmap(256,'redblue');
    cmap=flipud(cmap);
    colormap(cmap);
    set(gca,'FontSize',FS);
    tightmap;
    caxlim=max(abs(param(:)))
    caxlim=max(caxlim,0.001);
    caxis([-caxlim,caxlim]);
    c=colorbar
    set(c,'FontSize',FS)
    title(sprintf(['B_r (nT)  ',titlestring,' \n\n']));
    xlabel(sprintf('magnetic long. (deg.) \n\n'))
    ylabel(sprintf('magnetic lat. (deg.)\n\n\n'))
    hold on;
    ax=axis;
    plotm(cfg.sourcemlat, cfg.sourcemlon,'r^','MarkerSize',6,'LineWidth',2);
    hold off;

%    subplot(132);
    figure(2);
    clf;
    axesm('MapProjection','Mercator','MapLatLimit',mlatlimplot,'MapLonLimit',mlonlimplot);
    param=squeeze(Bthetatp(:,:,:,it))*1e9;
    pcolorm(MLAT,MLON,param);
    cmap=lbmap(256,'redblue');
    cmap=flipud(cmap);
    colormap(cmap);
    set(gca,'FontSize',FS);
    tightmap;
    caxlim=max(abs(param(:)))
    caxlim=max(caxlim,0.001);
    caxis([-caxlim,caxlim]);
    c=colorbar
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
    cmap=lbmap(256,'redblue');
    cmap=flipud(cmap);
    colormap(cmap);
    set(gca,'FontSize',FS);
    tightmap;
    caxlim=max(abs(param(:)))
    caxlim=max(caxlim,0.001);
    caxis([-caxlim,caxlim]);
    c=colorbar
    set(c,'FontSize',FS)
    title(sprintf(['B_\\phi (nT)  ',titlestring,' \n\n']));
    xlabel(sprintf('magnetic long. (deg.) \n\n'))
    ylabel(sprintf('magnetic lat. (deg.)\n\n\n'))
    hold on;
    ax=axis;
    plotm(cfg.sourcemlat, cfg.sourcemlon, 'r^','MarkerSize',6,'LineWidth',2);
    hold off;


    %ADD A MAP OF COASTLINES
%    if (license('test','Map_Toolbox'))
        load coastlines;
        [thetacoast,phicoast]=geog2geomag(coastlat,coastlon);
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
%        setm(gca,'MeridianLabel','on','ParallelLabel','on','MLineLocation',10,'PLineLocation',5,'MLabelLocation',10,'PLabelLocation',5);
        setm(gca,'MeridianLabel','on','ParallelLabel','on','MLineLocation',2,'PLineLocation',1,'MLabelLocation',2,'PLabelLocation',1);
        gridm on;
        print('-dpng',[direc,'/Brplots/',filename,'.png'],'-r300');
%        print('-depsc2',[direc,'/Brplots_eps/',filename,'.eps']);

%        subplot(132);
        figure(2);
        hold on;
        ax=axis;
        plotm(mlatcoast,mloncoast,'k-','LineWidth',1);
%        setm(gca,'MeridianLabel','on','ParallelLabel','on','MLineLocation',10,'PLineLocation',5,'MLabelLocation',10,'PLabelLocation',5);
        setm(gca,'MeridianLabel','on','ParallelLabel','on','MLineLocation',2,'PLineLocation',1,'MLabelLocation',2,'PLabelLocation',1);
        gridm on;
        print('-dpng',[direc,'/Bthplots/',filename,'.png'],'-r300');
%        print('-depsc2',[direc,'/Bthplots_eps/',filename,'.eps']);

%        subplot(133);
        figure(3);
        hold on;
        ax=axis;
        plotm(mlatcoast,mloncoast,'k-','LineWidth',1);
%        setm(gca,'MeridianLabel','on','ParallelLabel','on','MLineLocation',10,'PLineLocation',5,'MLabelLocation',10,'PLabelLocation',5);
        setm(gca,'MeridianLabel','on','ParallelLabel','on','MLineLocation',2,'PLineLocation',1,'MLabelLocation',2,'PLabelLocation',1);
        gridm on;
        print('-dpng',[direc,'/Bphiplots/',filename,'.png'],'-r300');
%        print('-depsc2',[direc,'/Bphiplots_eps/',filename,'.eps']);
%    end
    axis(ax);
end
