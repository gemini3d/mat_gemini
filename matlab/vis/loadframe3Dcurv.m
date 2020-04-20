function dat = loadframe3Dcurv(filename)

narginchk(1,1)
[~,~,ext] = fileparts(filename);

switch ext
  case '.h5', dat = loadframe3Dcurv_hdf5(filename);
  case '.dat', dat = loadframe3Dcurv_raw(filename);
  case '.nc', error('NetCDF4 not yet handled in Matlab')
  otherwise, error(['unknown file type', filename])
end

lsp = 7;
lxs = simsize(filename);

dat.v1 = squeeze(sum(dat.ns(:,:,:,1:6) .* dat.vs1(:,:,:,1:6), 4) ./ dat.ns(:,:,:,lsp));

%% REORGANIZE ACCORDING TO MATLABS CONCEPT OF A 2D or 3D DATA SET
if lxs(2) == 1 || lxs(3) == 1  %a 2D simulations was done
  dat.ne=squeeze(dat.ns(:,:,:,lsp));

  dat.Ti = squeeze(sum(dat.ns(:,:,:,1:6) .* dat.Ts(:,:,:,1:6),4) ./ dat.ns(:,:,:,lsp));
  dat.Te = squeeze(dat.Ts(:,:,:,lsp));

%  [X3,X1]=meshgrid(x3,x1);
else    %full 3D run
  dat.ne = dat.ns(:,:,:,lsp);

  dat.Ti = sum(dat.ns(:,:,:,1:6) .* dat.Ts(:,:,:,1:6),4) ./ dat.ns(:,:,:,lsp);
  dat.Te = dat.Ts(:,:,:,lsp);
end

end % function
