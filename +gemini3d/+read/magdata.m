function dat = magdata(direc,gridsize)

arguments
  direc (1,1) string
  gridsize (1,3) {mustBeNumeric} = [-1,-1,-1]    % [lr,ltheta,lphi] grid sizes
end

direc = gemini3d.fileio.expanduser(direc);
basemagdir = fullfile(direc, 'magfields');

flatlist=false;

%SIMULATION META-DATA
cfg = gemini3d.read.config(direc);
dat.times = cfg.times;

%LOAD/CONSTRUCT THE FIELD POINT GRID
switch cfg.file_format
  case 'dat'
    fn = fullfile(direc,'inputs/magfieldpoints.dat');
    assert(isfile(fn), fn + " not found")

    fid=fopen(fn, 'r');
    lpoints=fread(fid,1,'integer*4');
    r=fread(fid,lpoints,'real*8');
    theta=fread(fid,lpoints,'real*8');    %by default these are read in as a row vector, AGHHHH!!!!!!!!!
    phi=fread(fid,lpoints,'real*8');
    fclose(fid);
  case 'h5'
    fn = fullfile(direc,'inputs/magfieldpoints.h5');
    assert(isfile(fn), fn + " not found")

    lpoints = h5read(fn, "/lpoints");
    r = double(h5read(fn, "/r"));
    theta = double(h5read(fn, "/theta"));
    phi = double(h5read(fn, "/phi"));
  otherwise, error('Unrecognized input field point file format %s', cfg.file_format)
end

% Reorganize the field points if the user has specified a grid size
if any(gridsize < 0)
  gridsize=[lpoints,1,1];    % just return a flat list if the user has not specified
  flatlist=true;
end %if
lr=gridsize(1); ltheta=gridsize(2); lphi=gridsize(3);
r=reshape(r(:),gridsize);
theta=reshape(theta(:),gridsize);
phi=reshape(phi(:),gridsize);

% Bit of error checking here
assert(lpoints == prod(gridsize), 'Incompatible data size and grid specification...')

% Create grid alt, magnetic latitude, and longitude (assume input points
% have been permuted in this order...
mlat=90-theta*180/pi;
mlon=phi*180/pi;
if ~flatlist   % we have a grid of points
  [~,ilatsort]=sort(mlat(1,:,1));    %mlat runs against theta...
  dat.mlat=squeeze(mlat(1,ilatsort,1));
  [~,ilonsort]=sort(mlon(1,1,:));
  dat.mlon=squeeze(mlon(1,1,ilonsort));
  dat.r=r(:,1,1);    % assume already sorted properly
else    % we have a flat list of points
  ilatsort=1:lpoints;
  ilonsort=1:lpoints;
  dat.mlat=mlat(:);
  dat.mlon=mlon(:);
  dat.r=r(:);
end %if

%THESE DATA ARE ALMOST CERTAINLY NOT LARGE SO LOAD THEM ALL AT ONCE (CAN
%CHANGE THIS LATER).  NOTE THAT THE DATA NEED TO BE SORTED BY MLAT,MLON AS
%WE GO
dat.Brt=zeros(lr,ltheta,lphi,length(cfg.times));
dat.Bthetat=zeros(lr,ltheta,lphi,length(cfg.times));
dat.Bphit=zeros(lr,ltheta,lphi,length(cfg.times));

for it=2:length(cfg.times)-1    %starts at second time step due to weird magcalc quirk
  filename = gemini3d.datelab(cfg.times(it));

  if ~isfile(fullfile(basemagdir, filename + "." + cfg.file_format))
    disp("SKIP: Could not find: " + filename)
    continue
  end

  switch cfg.file_format
  case 'dat'
    fid=fopen(fullfile(basemagdir,strcat(filename,".dat")),'r');
    data=fread(fid,lpoints,'real*8');
  case 'h5'
    data = h5read(fullfile(basemagdir, filename + ".h5"), '/magfields/Br');
  end

  dat.Brt(:,:,:,it)=reshape(data,[lr,ltheta,lphi]);
  if ~flatlist
    dat.Brt(:,:,:,it)=dat.Brt(:,ilatsort,:,it);
    dat.Brt(:,:,:,it)=dat.Brt(:,:,ilonsort,it);
  end

  switch cfg.file_format
  case 'dat'
    data=fread(fid,lpoints,'real*8');
  case 'h5'
    data = h5read(fullfile(direc,'magfields', filename + ".h5"), '/magfields/Btheta');
  end

  dat.Bthetat(:,:,:,it)=reshape(data,[lr,ltheta,lphi]);
  if ~flatlist
    dat.Bthetat(:,:,:,it)=dat.Bthetat(:,ilatsort,:,it);
    dat.Bthetat(:,:,:,it)=dat.Bthetat(:,:,ilonsort,it);
  end %if

  switch cfg.file_format
  case 'dat'
    data=fread(fid, lpoints,'real*8');
  case 'h5'
    data = h5read(fullfile(direc,'magfields', filename + ".h5"), '/magfields/Bphi');
  end

  dat.Bphit(:,:,:,it)=reshape(data,[lr,ltheta,lphi]);
  if ~flatlist
    dat.Bphit(:,:,:,it)=dat.Bphit(:,ilatsort,:,it);
    dat.Bphit(:,:,:,it)=dat.Bphit(:,:,ilonsort,it);
  end

  if exist("fid", "var")
    fclose(fid);
  end
end

end %function
