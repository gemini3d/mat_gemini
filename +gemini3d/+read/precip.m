function dat = precip(filename, time)
arguments
  filename (1,1) string
  time datetime {mustBeScalarOrEmpty} = datetime.empty
end

if ~isempty(time)
  filename = gemini3d.find.frame(filename, time, "required", true);
end

[~,~,ext] = fileparts(filename);

switch ext
  case '.h5', dat = load_h5(filename);
  case '.nc', dat = load_nc(filename);
  otherwise, error('gemini3d:read:precip:value_error', 'unsupported file type %s', filename)
end

end % function


function dat = load_h5(filename)

dat = struct();

for k = ["Qp", "E0p"]
	try
    dat.(extractBefore(k, strlength(k))) = h5read(filename, "/" + k);
  end
end

end % function


function dat = load_nc(filename)

dat = struct();

for k = ["Qp", "E0p"]
	try %#ok<*TRYNC>
    dat.(extractBefore(k, strlength(k))) = ncread(filename, k);
  end
end

end % function
