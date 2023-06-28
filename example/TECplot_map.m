function TECplot_map(direc)
arguments
  direc (1,1) string {mustBeFolder}
end

gemini3d.sys.check_stdlib()

stdlib.makedir(fullfile(direc, "TECplots"));    %store output plots with the simulation data
stdlib.makedir(fullfile(direc, "TECplots_eps"));    %store output plots with the simulation data


%LOAD THE COMPUTED TEC DATA
dat = load(fullfile(direc, "vTEC.mat"), "mlong", "mlat", "dvTEC");

mlon = dat.mlong;
mlat = dat.mlat;

%SIMULATION META-DATA
cfg = gemini3d.read.config(direc);

%TABULATE THE SOURCE LOCATION
% thdist = pi/2 - deg2rad(cfg.sourcemlat);    %zenith angle of source location
% phidist = deg2rad(cfg.sourcemlon);

figure(1);
%set(gcf,'PaperPosition',[0 0 4 8]);


%MAKE THE PLOTS AND SAVE TO A FILE
for it=1:length(cfg.times)
    %CREATE A MAP AXIS
    figure(1);
    clf;
%    FS=16;
    FS=10;

    filename = gemini3d.datelab(cfg.times(it)) + ".h5";
    disp(filename)

    mlatlimplot=double([min(mlat)-0.5,max(mlat)+0.5]);
    mlonlimplot=double([min(mlon)-0.5,max(mlon)+0.5]);
    axesm('MapProjection','Mercator','MapLatLimit',mlatlimplot,'MapLonLimit',mlonlimplot);
    % param=dvTEC(:,:,it);
    param = dat.dvTEC(:,:,it) - dat.dvTEC(:,:,5);   %flat-field dvTEC just in case
    %imagesc(mlon,mlat,param);
    mlatlim=double([min(mlat),max(mlat)]);
    mlonlim=double([min(mlon),max(mlon)]);
    [MLAT,MLON]=meshgrat(mlatlim,mlonlim,size(param)); %#ok<MESHGRAT>
    % possibly replace like:
    % [MLAT, MLON] = ndgrid(linspace(mlatlim(1),mlatlim(2), size(param), ...
    %                        linspace(mlonlim(1), mlonlim(2), size(param))
    pcolorm(MLAT,MLON,param);
%    cmap=colormap(old_parula(256));
%    colormap(bwr());
    cmap=lbmap(256,'redblue');
    cmap=flipud(cmap);
    colormap(cmap);
    set(gca,'FontSize',FS);
    tightmap;
    if isMATLABReleaseOlderThan('R2022a')
        caxis([-0.5,0.5]) %#ok<CAXIS>
    else
    %    clim([-3,3]);
        clim([-0.5,0.5])
    end
    c=colorbar;
    set(c,'FontSize',FS)
    xlabel(c,'\Delta vTEC (TECU)')
    xlabel(sprintf('magnetic long. (deg.)\n\n'))
    ylabel(sprintf('magnetic lat. (deg.)\n\n\n'))
    hold on;
    plotm(cfg.sourcemlat,cfg.sourcemlon,'r^','MarkerSize',10,'LineWidth',2);
    hold off;

    title(string(cfg.times(it)))
    %gridm;

    %ADD A MAP OF COASTLINES
    load("coastlines", "coastlat", "coastlon")
    [thetacoast,phicoast] = gemini3d.geog2geomag(coastlat,coastlon);
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
