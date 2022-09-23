function dat = precip(filename, time)
arguments
  filename (1,1) string {mustBeNonzeroLengthText}
  time datetime {mustBeScalarOrEmpty} = datetime.empty
end

gemini3d.sys.check_stdlib()

filename = stdlib.fileio.expanduser(filename);

if ~isempty(time)
  filename = gemini3d.find.frame(filename, time);
end

assert(~isempty(filename) && isfile(filename), "Invalid simulation directory: no precipitation data file found")


dat = load_h5(filename);

end % function


function dat = load_h5(filename)

dat.Q = h5read(filename, "/Qp");
dat.E0 = h5read(filename, "/E0p");

end % function
