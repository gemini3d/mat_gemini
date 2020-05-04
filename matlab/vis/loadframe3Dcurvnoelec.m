function dat = loadframe3Dcurvnoelec(filename)
%% READ IN SIMULATION DATA WITH NO ELECTRODYNAMIC PARAMS SUCH AS FROM AN INPUT FILE
narginchk(1,1)

narginchk(1,1)
[~,~,ext] = fileparts(filename);

switch ext
  case '.h5', dat = loadframe3Dcurvnoelec_hdf5(filename);
  case '.dat', dat = loadframe3Dcurvnoelec_raw(filename);
  case '.nc', error('loadframe3Dcurvnoelec:not_implemented', 'NetCDF4')
  otherwise, error('loadframe3Dcurvnoelec:not_implemented %s',filename)
end

%% REORGANIZE ACCORDING TO MATLABS CONCEPT OF A 2D or 3D DATA SET
lsp = 7;
lxs = simsize(filename);

dat.v1=sum(dat.ns(:,:,:,1:6) .* dat.vs1(:,:,:,1:6),4) ./ dat.ns(:,:,:,lsp);

if any(lxs(2:3) == 1)   % 2D simulation
  dat.ne = squeeze(dat.ns(:,:,:,lsp));
  dat.Ti = squeeze(sum(dat.ns(:,:,:,1:6) .* dat.Ts(:,:,:,1:6),4) ./ dat.ns(:,:,:,lsp));
  dat.Te = squeeze(dat.Ts(:,:,:,lsp));
else    %full 3D run
  dat.ne = dat.ns(:,:,:,lsp);
  dat.Ti = sum(dat.ns(:,:,:,1:6) .* dat.Ts(:,:,:,1:6),4) ./ dat.ns(:,:,:,lsp);
  dat.Te = dat.Ts(:,:,:,lsp);
end
end
