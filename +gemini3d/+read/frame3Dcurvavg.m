function dat = frame3Dcurvavg(filename, vars)
arguments
  filename (1,1) string {mustBeFile}
  vars (1,:) string = string.empty
end

if isempty(vars)
  vars = ["ne", "Ti", "Te", "J1", "J2", "J3", "v1", "v2", "v3", "Phitop"];
end

dat = frame3Dcurvavg_hdf5(filename, vars);
dat.filename = filename;

for n = vars
  dat.lxs = size(dat.(n), 1:3);
end

end % function
