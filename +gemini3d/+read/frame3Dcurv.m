function dat = frame3Dcurv(filename, vars)
arguments
  filename (1,1) string {mustBeFile}
  vars (1,:) string = string.empty
end

if isempty(vars)
  vars = ["ne", "Ti", "Te", "v1", "v2", "v3", "J1", "J2", "J3", "Phitop"];
end

dat = frame3Dcurv_hdf5(filename, vars);

dat.filename = filename;

dat = curv_derived(dat, vars);

end % function
