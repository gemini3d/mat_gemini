function dat = frame3Dcurvne(filename)
arguments
  filename (1,1) string {mustBeFile}
end

dat.ne = h5read(filename, '/ne');

dat.filename = filename;
dat.lxs = size(dat.ne, 1:3);

end % function
