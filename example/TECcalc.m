gemini3d.sys.check_stdlib()

%SIMULATIONS LOCAITONS
%simname='tohoku20113D_lowres/';
%simname_control='tohoku20113D_lowres_control/';
simname='mooreOK3D_hemis_medres_corrected/';
simname_control='mooreOK3D_hemis_medres_corrected_control/';
basedir='~/simulations/';
direc = fullfile(basedir, simname);
direc_control = fullfile(basedir, simname_control);

stdlib.makedir(fullfile(direc, "TECplots"));    %store output plots with the simulation data


%READ IN THE SIMULATION INFORMATION
cfg = gemini3d.read.config(direc);


%WE ALSO NEED TO LOAD THE GRID FILE (UNLESS IT ALREADY EXISTS IN THE WORKSPACE)
if ~exist('xg','var')
  disp('Reading dist. grid...')
  xg = gemini3d.read.grid(direc);
  lx1=xg.lx(1); lx2=xg.lx(2); lx3=xg.lx(3);
  lh=lx1;   %possibly obviated in this version - need to check
  if (lx3==1)
    flag2D=1;
  else
    flag2D=0;
  end
end


%ON THE OFF CHANCE THE CONTROL GRID IS DIFFERENT, LOAD IT TOO
if ~exist('xgc','var')
  disp('Reading control grid...')
  xgc=gemini3d.read.grid(direc_control);
  lx1c=xgc.lx(1); lx2c=xgc.lx(2); lx3c=xgc.lx(3);
  lhc=lx1c;   %possibly obviated in this version - need to check
end


%DEFINE A CENTER AND REGION OF INTEREST
if (isempty(cfg.sourcemlat))    %in case this run didn't have a disturbance!
  cfg.sourcemlat = pi/2 - rad2deg(mean(xg.theta, 'all'));
  cfg.sourcemlon = rad2deg(mean(xg.phi, 'all'));
end
thdist = pi/2 - deg2rad(cfg.sourcemlat);    %zenith angle of source location
phidist = deg2rad(cfg.sourcemlon);


%ANGULAR RANGE TO COVER FOR TEC CALCULATIONS
%dang=3.5;
dang=10;
%dang=180;

%NEW (PLOT) GRID SIZE IN R,TH
Re=6370e3;
%lth=500;
lth=3000;
%lr=250;
lr=300;
lphi=600;


%DEFINE A GRID FOR THE INTERPOLATION
rvals=xg.r(1:lh,:,:);
thvals=xg.theta(1:lh,:,:);
phivals=xg.phi(1:lh,:,:);
rmin=min(rvals, [], 'all');
rmax=max(rvals, [], 'all');
thmin=min(thvals, [], 'all');
thmax=max(thvals, [], 'all');
phimin=min(phivals, [], 'all');
phimax=max(phivals, [], 'all');

theta=linspace(thmin,thmax,lth);
r=linspace(rmin,rmax,lr)';
if (~flag2D)       %in case a 2D run has been done, we assume that it is done in x1,x2 (not x1,x3, which would require some changes)
  phi=linspace(phimin,phimax,lphi);
else
  phi=phidist;
end
[THETA,R,PHI]=meshgrid(theta,r,phi);


%THESE ARE DIPOLE COORDINATES OF
qI=(Re./R).^2.*cos(THETA);
pI=R./Re./sin(THETA).^2;
X3I=PHI;   %phi variable name already used, this is a bit kludgey


ith1=find(theta-(thdist-dang*pi/180)>0, 1 );
if (isempty(ith1))
   ith1=1;
end
ith2=find(theta-(thdist+dang*pi/180)>0, 1 );
if (isempty(ith2))
   ith2=numel(theta);
end
if (~flag2D)
  iphi1=find(phi-(phidist-dang*pi/180)>0, 1 );
  if (isempty(iphi1))
    iphi1=1;
  end
  iphi2=find(phi-(phidist+dang*pi/180)>0, 1 );
  if (isempty(iphi2))
    iphi2=numel(phi);
  end
else
  iphi1=1;
  iphi2=1;
end
mlat=fliplr(90-theta(ith1:ith2)*180/pi);
mlong=phi(iphi1:iphi2)*180/pi;
itop=lr-1;


%MAIN LOOP FOR TEC CALCULATION
fprintf('Processing %d files...\n',numel(cfg.times))
vTEC=[];
vTEC_control=[];
dvTEC=[];

for it=1:length(cfg.times)
    %LOAD DIST. FILE
    dat = gemini3d.read.frame(direc, "time", cfg.times(it), "vars", "ne");

    %DEFINE A MESHGRID BASED ON SIMULATION OUTPUT AND DO INTERPOLATION
    if (~flag2D)
      fprintf('3D interpolation...\n')
      x1=xg.x1(3:end-2);
      x2=xg.x2(3:end-2);
      x3=xg.x3(3:end-2);
      [X2,X1,X3]=meshgrid(x2(:),x1(1:lh)',x3(:));   %read.frame overwrites this (sloppy!) so redefine eeach time step

      neI=interp3(X2,X1,X3,dat.ne,pI(:),qI(:),X3I(:));
    else
      fprintf('2D interpolation...\n')
      x1=xg.x1(3:end-2);
      x2=xg.x2(3:end-2);
      x3=xg.x3(3:end-2);
      [X2,X1]=meshgrid(x2(:),x1(1:lh)');

      neI=interp2(X2,X1,dat.ne,pI(:),qI(:));
    end


    %RESHAPE AND GET RID OF NANS
    neI=reshape(neI,size(R));
    neI(isnan(neI))=0;


    %LOAD CONTROL SIMULATION
    dat = gemini3d.read.frame(direc_control, "time", cfg.times(it), "vars", "ne");


    %DEFINE A MESHGRID BASED ON CONTROL SIMULATION OUTPUT AND DO INTERPOLATION
    if (~flag2D)
      fprintf('3D interpolation...\n')
      x1c=xgc.x1(3:end-2);
      x2c=xgc.x2(3:end-2);
      x3c=xgc.x3(3:end-2);
      [X2c,X1c,X3c]=meshgrid(x2c(:),x1c(1:lhc)',x3c(:));   %read.frame overwrites this (sloppy!) so redefine eeach time step

      neI_control=interp3(X2c,X1c,X3c,dat.ne,pI(:),qI(:),X3I(:));
    else
      fprintf('2D interpolation...\n')
      x1c=xgc.x1(3:end-2);
      x2c=xgc.x2(3:end-2);
      x3c=xgc.x3(3:end-2);
      [X2c,X1c]=meshgrid(x2c(:),x1c(1:lhc)');

      neI_control=interp2(X2c,X1c,dat.ne,pI(:),qI(:));
    end


    %RESHAPE AND GET RID OF NANS IN CONTROL SIMULATION
    neI_control=reshape(neI_control,size(R));
    inds=find(isnan(neI_control));
    neI_control(inds)=0;


    %NOW INTEGRATIOPN TO GET TEC
    if ~flag2D
      fprintf('Integrating in 3D...\n');
      intne=cumtrapz(r,neI);               %the radial dimension is the first of the neI array
      TECrawnow=intne(itop,ith1:ith2,iphi1:iphi2);
      TECrawnow=squeeze(TECrawnow);        %now the arrays are mlat (1st dim), mlon (2nd dim)
      TECrawnow=flipud(TECrawnow)/1e16;    %mlat runs against x2, scale to TECU
      vTEC=cat(3,vTEC,TECrawnow);          %compile a time series array

      intne=cumtrapz(r,neI_control);               %the radial dimension is the first of the neI array
      TECrawnow=intne(itop,ith1:ith2,iphi1:iphi2);
      TECrawnow=squeeze(TECrawnow);        %now the arrays are mlat (1st dim), mlon (2nd dim)
      TECrawnow=flipud(TECrawnow)/1e16;    %mlat runs against x2, scale to TECU
      vTEC_control=cat(3,vTEC_control,TECrawnow);          %compile a time series array

      dvTEC=cat(3,dvTEC,vTEC(:,:,it)-vTEC_control(:,:,it));
    else
      fprintf('Integrating in 2D...\n');
      intne=cumtrapz(r,neI);               %first dim is radial, as with 3D case
      TECrawnow=intne(itop,ith1:ith2,iphi1:iphi2);
      TECrawnow=squeeze(TECrawnow);        %now the arrays are mlat (1st dim)
      TECrawnow=TECrawnow(:);              %force into a column vector since squeeze will make a row
      TECrawnow=flipud(TECrawnow)/1e16;    %mlat runs against x2, scale to TECU
      vTEC=cat(2,vTEC,TECrawnow);          %compile a time series array

      intne=cumtrapz(r,neI_control);               %first dim is radial, as with 3D case
      TECrawnow=intne(itop,ith1:ith2,iphi1:iphi2);
      TECrawnow=squeeze(TECrawnow);        %now the arrays are mlat (1st dim)
      TECrawnow=TECrawnow(:);              %force into a column vector since squeeze will make a row
      TECrawnow=flipud(TECrawnow)/1e16;    %mlat runs against x2, scale to TECU
      vTEC_control=cat(2,vTEC_control,TECrawnow);          %compile a time series array

      dvTEC=cat(2,dvTEC,vTEC(:,it)-vTEC_control(:,it));    %not vTEC now a 2D array
    end


    %PLOT THE TOTAL ELECTRON CONTENT EACH TIME FRAME IF WE HAAVE DONE A 3D SIMULATION, OTHERWISE WAIT UNTIL THE END OR A SINGLE PLOT
    if (~flag2D)
      disp('Printing TEC plot for current time frame...')
      direc = [basedir, simname];
      filename = datelab(cfg.times(it));
      FS=18;
      imagesc(mlong,mlat,dvTEC(:,:,it));
      colormap(parula(256));
%       set(gca,'FontSize',FS);
      axis xy;
      axis tight;
      caxlim= max(abs(dvTEC(:,:,it)), [], 'all');
      caxlim=max(caxlim,0.01);
      if verLessThan('matlab', '9.12')
        caxis([-1*caxlim, caxlim]) %#ok<CAXIS>
      else
        clim([-1*caxlim, caxlim])
  %      clim([-4,4]);
      end
      c=colorbar;
%       set(c,'FontSize',FS)
      xlabel(c,'\Delta vTEC (TECU)')
      xlabel('magnetic long. (deg.)')
      ylabel('magnetic lat. (deg.)')
      hold on;
      ax=axis;
      plot(cfg.sourcemlon,cfg.sourcemlat,'r^','MarkerSize',10,'LineWidth',2);
      hold off;
      titlestring = string(cfg.times(it));
      title(titlestring);
      print('-dpng',[direc,'/TECplots/',filename,'.png'],'-r300');
    end
end


%CREATE A FULL TIME SERIES PLOT IF IN 2D
if (flag2D)
  disp('Printing TEC plot for entire time series.')
  direc = fullfile(basedir,simname);
  FS=18;

  imagesc(cfg.times, mlat, dvTEC(:,:));
  colormap(parula(256));
%   set(gca,'FontSize',FS);
  axis xy;
  datetick;
  axis tight;
  if verLessThan('matlab', '9.12')
    caxis([-max(abs(dvTEC), [], 'all'), max(abs(dvTEC), [], 'all')]) %#ok<CAXIS>
  else
    clim([-max(abs(dvTEC), [], 'all'), max(abs(dvTEC), [], 'all')])
  end
  c=colorbar;
%   set(c,'FontSize',FS)
  xlabel(c,'\Delta vTEC (TECU)')
  xlabel('UT')
  ylabel('magnetic lat. (deg.)')
  hold on;
  ax=axis;
  yline(cfg.sourcemlat,'r--','MarkerSize',10,'LineWidth',2);
  hold off;
  print('-dpng',[direc,'/TECplots/TEC_timeseries.png'],'-r300');
end


%SAVE THE DATA TO A .MAT FILE IN CASE WE3 NEED IT LATER
t=cfg.times;
save([direc,'/vTEC.mat'],'mlat','mlong','t','cfg','*vTEC*','-v7');
