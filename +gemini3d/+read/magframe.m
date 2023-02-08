function dat = magframe(filename, time)

% example use
% dat = gemini3d.read.magframe(filename)
% dat = gemini3d.read.magframe(folder, datetime)

arguments
  filename (1,1) string {mustBeNonzeroLengthText}
  time datetime {mustBeScalarOrEmpty} = datetime.empty
end

gemini3d.sys.check_stdlib()

% make sure to add the default directory where the magnetic fields are to
% be found

filename = stdlib.expanduser(filename);

direc = fileparts(filename);
basemagdir = fullfile(direc,"magfields");

% find the actual filename if only the directory was given
if ~isfile(filename)
  if ~isempty(time)
    filename = gemini3d.find.frame(basemagdir, time);
  end
end

% some times might not have magnetic field computed
if isempty(filename)
  disp("SKIP: read.magframe %s", string(time))
  return
end

% load and construct the magnetic field point grid
fn = fullfile(direc,'inputs/magfieldpoints.h5');
assert(isfile(fn), fn + " not found")

lpoints = h5read(fn, "/lpoints");
r = double(h5read(fn, "/r"));
theta = double(h5read(fn, "/theta"));
phi = double(h5read(fn, "/phi"));
gridsize=reshape(h5read(fn,"/gridsize"),[1,3]);

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

data = h5read(filename, '/magfields/Br');

dat.Br(:,:,:)=reshape(data,[lr,ltheta,lphi]);
if ~flatlist
  dat.Br(:,:,:)=dat.Br(:,ilatsort,:);
  dat.Br(:,:,:)=dat.Br(:,:,ilonsort);
end

data = h5read(filename, '/magfields/Btheta');

dat.Btheta(:,:,:)=reshape(data,[lr,ltheta,lphi]);
if ~flatlist
  dat.Btheta(:,:,:)=dat.Btheta(:,ilatsort,:);
  dat.Btheta(:,:,:)=dat.Btheta(:,:,ilonsort);
end %if

data = h5read(filename, '/magfields/Bphi');

dat.Bphi(:,:,:)=reshape(data,[lr,ltheta,lphi]);
if ~flatlist
  dat.Bphi(:,:,:)=dat.Bphi(:,ilatsort,:);
  dat.Bphi(:,:,:)=dat.Bphi(:,:,ilonsort);
end

end % function
