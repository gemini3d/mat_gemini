function dat = Efield(filename, time)
arguments
  filename (1,1) string
  time datetime {mustBeScalarOrEmpty} = datetime.empty
end

if ~isempty(time)
  filename = gemini3d.find.frame(filename, time);
end

[~,~,ext] = fileparts(filename);

switch ext
  case '.h5', dat = load_h5(filename);
  case '.nc', dat = load_nc(filename);
  otherwise, error("gemini3d:read:Efield:value_error", "unsupported file type " + filename)
end

end % function


function dat = load_h5(filename)

dat = struct();

for k = ["flagdirich", "Exit", "Eyit", "Vminx1it", "Vmaxx1it", "Vminx2ist", "Vmaxx2ist", "Vminx3ist", "Vmaxx3ist"]
  try
    dat.(k) = h5read(filename, "/" + k);
  end
end

end % function


function dat = load_nc(filename)

dat = struct();

for k = ["flagdirich", "Exit", "Eyit", "Vminx1it", "Vmaxx1it", "Vminx2ist", "Vmaxx2ist", "Vminx3ist", "Vmaxx3ist"]
  try %#ok<*TRYNC>
   dat.(k) = ncread(filename, "/" + k);
  end
end

end % function
