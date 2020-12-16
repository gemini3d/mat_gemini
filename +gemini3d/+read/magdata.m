function [dat,times] = magdata(direc,gridsize)

arguments
  direc (1,1) string
  gridsize (1,3) {mustBeNumeric}    % [lr,ltheta,lphi] grid sizes
end

%SIMULATION META-DATA
cfg = gemini3d.read.config(direc);
times=cfg.times;
lt=numel(cfg.times);


%LOAD/CONSTRUCT THE FIELD POINT GRID
basemagdir= fullfile(direc,'magfields/');
fid=fopen(fullfile(basemagdir,'input/magfieldpoints.dat'),'r');    %needs some way to know what the input file is, maybe force fortran code to use this filename...
lpoints=fread(fid,1,'integer*4');

if (lpoints ~= prod(gridsize))
    error('Incompatible data size and grid specification...')
end %if

r=fread(fid,lpoints,'real*8');
theta=fread(fid,lpoints,'real*8');    %by default these are read in as a row vector, AGHHHH!!!!!!!!!
phi=fread(fid,lpoints,'real*8');
fclose(fid);


% Reorganize the field points if the user has specified a grid size
if (isempty(gridsize))
    gridsize=[lpoints,1,1];    % just return a flat list if the user has not specified
end %if
lr=gridsize(1); ltheta=gridsize(2); lphi=gridsize(3);
r=reshape(r(:),gridsize);
theta=reshape(theta(:),gridsize);
phi=reshape(phi(:),gridsize);


% Create grid alt, magnetic latitude, and longitude (assume input points
% have been permuted in this order...
mlat=90-theta*180/pi;
[~,ilatsort]=sort(mlat(1,:,1));    %mlat runs against theta...
dat.mlat=mlat(1,ilatsort,1);
mlon=phi*180/pi;
[~,ilonsort]=sort(mlon(1,1,:));
dat.mlon=mlon(1,1,ilonsort);
dat.r=r(:,1,1);    % assume already sorted properly


%THESE DATA ARE ALMOST CERTAINLY NOT LARGE SO LOAD THEM ALL AT ONCE (CAN
%CHANGE THIS LATER).  NOTE THAT THE DATA NEED TO BE SORTED BY MLAT,MLON AS
%WE GO
dat.Brt=zeros(lr,ltheta,lphi,lt);
dat.Bthetat=zeros(lr,ltheta,lphi,lt);
dat.Bphit=zeros(lr,ltheta,lphi,lt);

for it=2:lt-1    %starts at second time step due to weird magcalc quirk
    filename= gemini3d.datelab(times(it));
    
    if (~exist(strcat(basemagdir,"/",filename,".dat"),'file') & ...
            ~exist(strcat(basemagdir,"/",filename,".h5"),'file') & ...
            ~exist(strcat(basemagdir,"/",filename,".nc"),'file'))
        disp(strcat("Could not find:  ",filename," skipping..."));
        continue;
    end %if
        
    if(cfg.file_format == 'dat')
        fid=fopen(fullfile(basemagdir,strcat(filename,".dat")),'r');
    end %if
    
    if(cfg.file_format == 'dat')
        fid=fopen(fullfile(basemagdir,strcat(filename,".dat")),'r');
        data=fread(fid,lpoints,'real*8');
    elseif(cfg.file_format == 'h5')
        data = h5read(strcat(basemagdir,'/',filename,'.h5'),'/magfields/Br');
    end
    
    dat.Brt(:,:,:,it)=reshape(data,[lr,ltheta,lphi]);
    dat.Brt(:,:,:,it)=dat.Brt(:,ilatsort,:,it);
    dat.Brt(:,:,:,it)=dat.Brt(:,:,ilonsort,it);
    
    if(cfg.file_format == 'dat')
        data=fread(fid,lpoints,'real*8');
    elseif(cfg.file_format == 'h5')
        data = h5read(strcat(direc,'magfields/',filename,'.h5'),'/magfields/Btheta');
    end
    
    dat.Bthetat(:,:,:,it)=reshape(data,[lr,ltheta,lphi]);
    dat.Bthetat(:,:,:,it)=dat.Bthetat(:,ilatsort,:,it);
    dat.Bthetat(:,:,:,it)=dat.Bthetat(:,:,ilonsort,it);
    
    
    if(cfg.file_format == 'dat')
        data=fread(fid,lpoints,'real*8');
    elseif(cfg.file_format == 'h5')
        data = h5read(strcat(direc,'magfields/',filename,'.h5'),'/magfields/Bphi');
    end
    
    dat.Bphit(:,:,:,it)=reshape(data,[lr,ltheta,lphi]);
    dat.Bphit(:,:,:,it)=dat.Bphit(:,ilatsort,:,it);
    dat.Bphit(:,:,:,it)=dat.Bphit(:,:,ilonsort,it);
    
    if(cfg.file_format == 'dat')
        fclose(fid);
    end
end

end %function