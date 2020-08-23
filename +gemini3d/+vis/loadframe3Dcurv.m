function dat = loadframe3Dcurv(filename, vars)

narginchk(1,2)
[~,~,ext] = fileparts(filename);
assert(isfile(filename), 'not a file: %s', filename)

if nargin < 2 || isempty(vars)
  vars = {'ne', 'Ti', 'Te', 'v1', 'v2', 'v3', 'J1', 'J2', 'J3'};
end

switch ext
  case '.h5', dat = gemini3d.vis.loadframe3Dcurv_hdf5(filename, vars);
  case '.dat', dat = gemini3d.vis.loadframe3Dcurv_raw(filename, vars);
  case '.nc', dat = gemini3d.vis.loadframe3Dcurv_nc4(filename, vars);
  otherwise, error('loadframe3Dcurv:value_error', 'unknown file type %s', filename)
end

lsp = 7;

%% squeeze for 2D, OK for 3D too
if any(contains(vars, 'ne'))
  dat.ne = squeeze(dat.ns(:,:,:,lsp));
end
if any(contains(vars, 'Ti'))
  dat.Ti = squeeze(sum(dat.ns(:,:,:,1:6) .* dat.Ts(:,:,:,1:6),4) ./ dat.ns(:,:,:,lsp));
end
if any(contains(vars, 'Te'))
  dat.Te = squeeze(dat.Ts(:,:,:,lsp));
end
if any(contains(vars, 'v1'))
  dat.v1 = squeeze(sum(dat.ns(:,:,:,1:6) .* dat.vs1(:,:,:,1:6), 4) ./ dat.ns(:,:,:,lsp));
end

end % function
