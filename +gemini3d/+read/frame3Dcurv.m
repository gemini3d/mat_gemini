function dat = frame3Dcurv(filename, vars)
arguments
  filename (1,1) string
  vars (1,:) string = string.empty
end

[~,~,ext] = fileparts(filename);
assert(isfile(filename), "not a file: " + filename)

if isempty(vars)
  vars = ["ne", "Ti", "Te", "v1", "v2", "v3", "J1", "J2", "J3"];
end

switch ext
  case '.h5', dat = frame3Dcurv_hdf5(filename, vars);
  case '.dat', dat = frame3Dcurv_raw(filename);
  case '.nc', dat = frame3Dcurv_nc4(filename, vars);
  otherwise, error('frame3Dcurv:value_error', 'unknown file type %s', filename)
end

lsp = 7;

%% squeeze for 2D, OK for 3D too
if any(vars == "ne")
  dat.lxs = size(dat.ns, 1:3);
  dat.ne = squeeze(dat.ns(:,:,:,lsp));
end
if any(vars == "Ti")
  dat.lxs = size(dat.ns, 1:3);
  dat.Ti = squeeze(sum(dat.ns(:,:,:,1:6) .* dat.Ts(:,:,:,1:6),4) ./ dat.ns(:,:,:,lsp));
end
if any(vars == "Te")
  dat.lxs = size(dat.Ts, 1:3);
  dat.Te = squeeze(dat.Ts(:,:,:,lsp));
end
if any(vars == "v1")
  dat.lxs = size(dat.ns, 1:3);
  dat.v1 = squeeze(sum(dat.ns(:,:,:,1:6) .* dat.vs1(:,:,:,1:6), 4) ./ dat.ns(:,:,:,lsp));
end

end % function
