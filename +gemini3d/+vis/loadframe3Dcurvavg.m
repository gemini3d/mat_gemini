function dat = loadframe3Dcurvavg(filename, vars)
arguments
  filename (1,1) string
  vars (1,:) string = string.empty
end

[~,~,ext] = fileparts(filename);
assert(isfile(filename), "not a file: " + filename)

if isempty(vars)
  vars = ["ne", "Ti", "Te", "J1", "J2", "J3", "v1", "v2", "v3"];
end

switch ext
  case '.h5', dat = gemini3d.vis.loadframe3Dcurvavg_hdf5(filename, vars);
  case '.dat', dat = gemini3d.vis.loadframe3Dcurvavg_raw(filename);
  case '.nc', dat = gemini3d.vis.loadframe3Dcurvavg_nc4(filename, vars);
  otherwise, error('loadframe3Dcurvavg:value_error', 'unknown file type %s',filename)
end

%% squeeze is needed for 2D and OK for 3D
for n = vars
  dat.lxs = size(dat.(n), 1:3);
  dat.(n) = squeeze(dat.(n));
end

end % function
