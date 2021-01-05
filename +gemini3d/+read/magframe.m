function dat = magframe(filename,opts)

% example use
% dat = gemini3d.read.frame(filename)
% dat = gemini3d.read.frame(folder, "time", datetime)
% dat = gemini3d.read.frame(filename, "config", cfg)
% dat = gemini3d.read.frame(filename, "vars", vars)
%
% The "vars" argument allows loading a subset of variables.
% for example:
%
% gemini3d.read.frame(..., "ne")
% gemini3d.read.frame(..., ["ne", "Te"])

arguments
  filename (1,1) string
  opts.time datetime = datetime.empty
  opts.cfg struct = struct.empty
  opts.vars (1,:) string = string.empty
  opts.gridsize (1,3) {mustBeNumeric} = [-1,-1,-1]    % [lr,ltheta,lphi] grid sizes
end

dat = struct.empty;

% make sure to add the default directory where the magnetic fields are to
% be found
direc=fileparts(filename);
basemagdir = fullfile(direc, 'magfields');

% find the actual filename if only the directory was given
if ~isfile(filename)
  if ~isempty(opts.time)
    filename = gemini3d.find.frame(direc, opts.time);
  end
end

% do nothing if we were not provided a filename
if isempty(filename)
  return
end

% read the config file if one was not provided as input
if isempty(opts.cfg)
  cfg = gemini3d.read.config(fileparts(filename));
else
  cfg = opts.cfg;
end

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
  otherwise, error('Unrecognized input field point file format %s', cfg.file_format)
end

% Reorganize the field points if the user has specified a grid size
gridsize=opts.gridsize;
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

% read in the data for the requested time. return array of zeros if not
% present (can happen if the user only computes magnetic fields for select frames)...
%filename = gemini3d.datelab(cfg.times(it));

if ~isfile(fullfile(basemagdir, filename + "." + cfg.file_format))
    disp("gemini3d.read.magframe - SKIP: Could not find: " + filename)
    return;
end

switch cfg.file_format
    case 'dat'
        fid=fopen(fullfile(basemagdir,strcat(filename,".dat")),'r');
        data=fread(fid,lpoints,'real*8');
    case 'h5'
        data = h5read(fullfile(basemagdir, filename + ".h5"), '/magfields/Br');
end

dat.Br(:,:,:,it)=reshape(data,[lr,ltheta,lphi]);
if ~flatlist
    dat.Br(:,:,:,it)=dat.Br(:,ilatsort,:);
    dat.Br(:,:,:,it)=dat.Br(:,:,ilonsort);
end

switch cfg.file_format
    case 'dat'
        data=fread(fid,lpoints,'real*8');
    case 'h5'
        data = h5read(fullfile(direc,'magfields', filename + ".h5"), '/magfields/Btheta');
end

dat.Btheta(:,:,:,it)=reshape(data,[lr,ltheta,lphi]);
if ~flatlist
    dat.Btheta(:,:,:,it)=dat.Btheta(:,ilatsort,:);
    dat.Btheta(:,:,:,it)=dat.Btheta(:,:,ilonsort);
end %if

switch cfg.file_format
    case 'dat'
        data=fread(fid, lpoints,'real*8');
    case 'h5'
        data = h5read(fullfile(direc,'magfields', filename + ".h5"), '/magfields/Bphi');
end

dat.Bphit(:,:,:)=reshape(data,[lr,ltheta,lphi]);
if ~flatlist
    dat.Bphit(:,:,:)=dat.Bphit(:,ilatsort,:);
    dat.Bphit(:,:,:)=dat.Bphit(:,:,ilonsort);
end

if exist("fid", "var")
    fclose(fid);
end