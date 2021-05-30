function dat = frame3Dcurvavg(filename, vars)
arguments
  filename (1,1) string
  vars (1,:) string = string.empty
end

[~,~,ext] = fileparts(filename);
assert(isfile(filename), "not a file: " + filename)

if isempty(vars)
  vars = ["ne", "Ti", "Te", "J1", "J2", "J3", "v1", "v2", "v3", "Phitop"];
end

switch ext
  case '.h5', dat = frame3Dcurvavg_hdf5(filename, vars);
  case '.dat', dat = frame3Dcurvavg_raw(filename);
  case '.nc', dat = frame3Dcurvavg_nc4(filename, vars);
  otherwise, error('frame3Dcurvavg:value_error', 'unknown file type %s',filename)
end
dat.filename = filename;


for n = vars
  dat.lxs = size(dat.(n), 1:3);
end

end % function
