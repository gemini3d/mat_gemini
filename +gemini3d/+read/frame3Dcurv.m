function dat = frame3Dcurv(filename, vars)
arguments
  filename (1,1) string
  vars (1,:) string = string.empty
end

assert(isfile(filename), "not a file: " + filename)

if isempty(vars)
  vars = ["ne", "Ti", "Te", "v1", "v2", "v3", "J1", "J2", "J3", "Phitop"];
end

[~,~,ext] = fileparts(filename);
switch ext
  case '.h5', dat = frame3Dcurv_hdf5(filename, vars);
  case '.nc', dat = frame3Dcurv_nc4(filename, vars);
  case '.dat', dat = frame3Dcurv_raw(filename);
  otherwise, error('frame3Dcurv:value_error', 'unknown file type %s', filename)
end

dat.filename = filename;

dat = curv_squeeze(dat, vars);

end % function
