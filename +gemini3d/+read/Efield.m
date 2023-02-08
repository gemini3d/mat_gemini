function dat = Efield(filename, time)
arguments
  filename (1,1) string {mustBeNonzeroLengthText}
  time datetime {mustBeScalarOrEmpty} = datetime.empty
end

gemini3d.sys.check_stdlib()

if ~isempty(time)
  filename = gemini3d.find.frame(filename, time);
end

filename = stdlib.expanduser(filename);

assert(~isempty(filename) && isfile(filename), "Invalid simulation directory: no E-field file found")

dat = load_h5(filename);

end % function


function dat = load_h5(filename)

dat = struct();

Evars = ["flagdirich", "Exit", "Eyit", "Vminx1it", "Vmaxx1it", "Vminx2ist", "Vmaxx2ist", "Vminx3ist", "Vmaxx3ist"];
vars = stdlib.h5variables(filename);

for k = Evars
  if any(vars == k)
    dat.(k) = h5read(filename, "/" + k);
  end
end

end % function
