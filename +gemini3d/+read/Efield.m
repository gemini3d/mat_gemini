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
  otherwise, error("gemini3d:read:Efield:value_error", "unsupported file type " + filename)
end

end % function


function dat = load_h5(filename)

import stdlib.hdf5nc.h5variables

dat = struct();

Evars = ["flagdirich", "Exit", "Eyit", "Vminx1it", "Vmaxx1it", "Vminx2ist", "Vmaxx2ist", "Vminx3ist", "Vmaxx3ist"];
vars = h5variables(filename);

for k = Evars
  if any(vars == k)
    dat.(k) = h5read(filename, "/" + k);
  end
end

end % function
