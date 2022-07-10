function dat = frame3Dcurvne(filename)
arguments
  filename (1,1) string {mustBeNonzeroLengthText}
end

[~,~,ext] = fileparts(filename);

switch ext
  case '.h5', dat.ne = h5read(filename, '/ne');
  otherwise, error('gemini3d:read:frame3Dcurvne:value_error', 'unknown file type %s',filename)
end

dat.filename = filename;
dat.lxs = size(dat.ne, 1:3);

end % function
