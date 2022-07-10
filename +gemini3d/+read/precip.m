function dat = precip(filename, time)
arguments
  filename (1,1) string {mustBeNonzeroLengthText}
  time datetime {mustBeScalarOrEmpty} = datetime.empty
end

if ~isempty(time)
  filename = gemini3d.find.frame(filename, time);
end

[~,~,ext] = fileparts(filename);

switch ext
  case '.h5', dat = load_h5(filename);
  otherwise, error('gemini3d:read:precip:value_error', 'unsupported file type %s', filename)
end

end % function


function dat = load_h5(filename)

dat.Q = h5read(filename, "/Qp");
dat.E0 = h5read(filename, "/E0p");

end % function
