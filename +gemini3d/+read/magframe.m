function dat = magframe(filename,opts)

% example use
% dat = gemini3d.read.magframe(filename)
% dat = gemini3d.read.magframe(folder, "time", datetime)
% dat = gemini3d.read.magframe(filename, "config", cfg)

arguments
  filename (1,1) string {mustBeNonzeroLengthText}
  opts.time datetime {mustBeScalarOrEmpty} = datetime.empty
  opts.cfg struct {mustBeScalarOrEmpty} = struct.empty
  opts.gridsize (1,3) {mustBeInteger} = [-1,-1,-1]    % [lr,ltheta,lphi] grid sizes
end

% make sure to add the default directory where the magnetic fields are to
% be found
direc=fileparts(filename);
basemagdir = fullfile(direc,"magfields");

% find the actual filename if only the directory was given
if ~isfile(filename)
  if ~isempty(opts.time)
    filename = gemini3d.find.frame(basemagdir, opts.time);
  end
end

% some times might not have magnetic field computed
if isempty(filename)
  disp("SKIP: read.magframe %s", datestr(opts.time))
  return
end

% read the config file if one was not provided as input
if isempty(opts.cfg)
  cfg = gemini3d.read.config(direc);
else
  cfg = opts.cfg;
end

% temp grid size variable...
gridsize=opts.gridsize;

% load and construct the magnetic field point grid
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
    gridsize=reshape(h5read(fn,"/gridsize"),[1,3]);
  otherwise, error('Unrecognized input field point file format %s', cfg.file_format)
end

% Reorganize the field points if the user has specified a grid size
if any(gridsize < 0)
  gridsize=[lpoints,1,1];    % just return a flat list if the user has not specified
  flatlist=true;
else
  flatlist=false;
end %if
lr=gridsize(1); ltheta=gridsize(2); lphi=gridsize(3);
r=reshape(r(:),gridsize);
theta=reshape(theta(:),gridsize);
phi=reshape(phi(:),gridsize);

% Sanity check the grid size and total number of grid points
assert(lpoints == prod(gridsize), 'Incompatible data size and grid specification...')

% Create grid alt, magnetic latitude, and longitude (assume input points
% have been permuted in this order)...
mlat=90-theta*180/pi;
mlon=phi*180/pi;
if ~flatlist   % we have a grid of points
  [~,ilatsort]=sort(mlat(1,:,1));    %mlat runs against theta...
  dat(1).mlat=squeeze(mlat(1,ilatsort,1));
  [~,ilonsort]=sort(mlon(1,1,:));
  dat(1).mlon=squeeze(mlon(1,1,ilonsort));
  dat(1).r=r(:,1,1);    % assume already sorted properly
else    % we have a flat list of points
  ilatsort=1:lpoints;
  ilonsort=1:lpoints;
  dat(1).mlat=mlat(:);
  dat(1).mlon=mlon(:);
  dat(1).r=r(:);
end %if

% allocate output arrays
dat(1).Br=zeros(lr,ltheta,lphi);
dat(1).Btheta=zeros(lr,ltheta,lphi);
dat(1).Bphi=zeros(lr,ltheta,lphi);

switch cfg.file_format
  case 'dat'
%        fid=fopen(fullfile(basemagdir,strcat(filename,".dat")),'r');
    fid=fopen(filename,'r');
    data=fread(fid,lpoints,'real*8');
  case 'h5'
    data = h5read(filename, '/magfields/Br');
end

dat.Br(:,:,:)=reshape(data,[lr,ltheta,lphi]);
if ~flatlist
    dat.Br(:,:,:)=dat.Br(:,ilatsort,:);
    dat.Br(:,:,:)=dat.Br(:,:,ilonsort);
end

switch cfg.file_format
    case 'dat'
        data=fread(fid,lpoints,'real*8');
    case 'h5'
        data = h5read(filename, '/magfields/Btheta');
end

dat.Btheta(:,:,:)=reshape(data,[lr,ltheta,lphi]);
if ~flatlist
    dat.Btheta(:,:,:)=dat.Btheta(:,ilatsort,:);
    dat.Btheta(:,:,:)=dat.Btheta(:,:,ilonsort);
end %if

switch cfg.file_format
    case 'dat'
        data=fread(fid, lpoints,'real*8');
    case 'h5'
        data = h5read(filename, '/magfields/Bphi');
end

dat.Bphi(:,:,:)=reshape(data,[lr,ltheta,lphi]);
if ~flatlist
    dat.Bphi(:,:,:)=dat.Bphi(:,ilatsort,:);
    dat.Bphi(:,:,:)=dat.Bphi(:,:,ilonsort);
end

if exist("fid", "var")
    fclose(fid);
end
