function TECplot_map(direc)
arguments
  direc (1,1) string
end
gemini3d.fileio.makedir(direc + "/TECplots");    %store output plots with the simulation data
gemini3d.fileio.makedir(direc + "/TECplots_eps");    %store output plots with the simulation data


%LOAD THE COMPUTED TEC DATA
load(direc + "/vTEC.mat", "mlong", "mlat", "dvTEC");
mlon=mlong;


%SIMULATION META-DATA
cfg = gemini3d.read_config(direc);


%TABULATE THE SOURCE LOCATION
thdist = pi/2 - deg2rad(cfg.sourcemlat);    %zenith angle of source location
phidist = deg2rad(cfg.sourcemlon);


figure(1);
%set(gcf,'PaperPosition',[0 0 4 8]);


%MAKE THE PLOTS AND SAVE TO A FILE
for it=1:length(cfg.times)
    %CREATE A MAP AXIS
    figure(1);
    clf;
%    FS=16;
    FS=10;

    filename = gemini3d.datelab(cfg.times(it)) + ".dat";
    disp(filename)

    mlatlimplot=double([min(mlat)-0.5,max(mlat)+0.5]);
    mlonlimplot=double([min(mlon)-0.5,max(mlon)+0.5]);
    axesm('MapProjection','Mercator','MapLatLimit',mlatlimplot,'MapLonLimit',mlonlimplot);
    % param=dvTEC(:,:,it);
    param= dvTEC(:,:,it) - dvTEC(:,:,5);   %flat-field dvTEC just in case
    %imagesc(mlon,mlat,param);
    mlatlim=double([min(mlat),max(mlat)]);
    mlonlim=double([min(mlon),max(mlon)]);
    [MLAT,MLON]=meshgrat(mlatlim,mlonlim,size(param));
    pcolorm(MLAT,MLON,param);
%    cmap=colormap(old_parula(256));
%    colormap(bwr());
    cmap=lbmap(256,'redblue');
    cmap=flipud(cmap);
    colormap(cmap);
    set(gca,'FontSize',FS);
    tightmap;
%    caxis([-3,3]);
    caxis([-0.5,0.5]);
    c=colorbar;
    set(c,'FontSize',FS)
    xlabel(c,'\Delta vTEC (TECU)')
    xlabel(sprintf('magnetic long. (deg.)\n\n'))
    ylabel(sprintf('magnetic lat. (deg.)\n\n\n'))
    hold on;
    plotm(cfg.sourcemlat,cfg.sourcemlon,'r^','MarkerSize',10,'LineWidth',2);
    hold off;

    title(datestr(cfg.times(it)))
    %gridm;

    %ADD A MAP OF COASTLINES
    load("coastlines", "coastlat", "coastlon")
    [thetacoast,phicoast] = gemini3d.geog2geomag(coastlat,coastlon,year);
    mlatcoast=90-thetacoast*180/pi;
    mloncoast=phicoast*180/pi;

    if (360-cfg.sourcemlon<20)
        inds=find(mloncoast>180);
        mloncoast(inds)=mloncoast(inds)-360;
    end

    hold on
    plotm(mlatcoast,mloncoast,'k-','LineWidth',1);
    hold off
    setm(gca,'MeridianLabel','on','ParallelLabel','on','MLineLocation',10,'PLineLocation',5,'MLabelLocation',10,'PLabelLocation',5);
%    setm(gca,'MeridianLabel','on','ParallelLabel','on','MLineLocation',1,'PLineLocation',1,'MLabelLocation',1,'PLabelLocation',1);
    gridm on


    %PRINT THE THING
    print('-dpng',[direc,'/TECplots/',filename,'.png'],'-r300');
    print('-depsc2',[direc,'/TECplots_eps/',filename,'.eps']);
end
