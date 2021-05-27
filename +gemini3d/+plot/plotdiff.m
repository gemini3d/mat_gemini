function plotdiff(new_path, ref_path, name, time)
% plot differences between two Gemini simulation files for a variable
% Two input methods:
% 1. new_path, ref_path are directories if time is specified
% 2. new_path, ref_path are filenames if time is not specified
%
% name is the variable name to plot the difference of

arguments
  new_path (1,1) string
  ref_path (1,1) string
  name (1,1) string
  time datetime {mustBeScalarOrEmpty} = datetime.empty
end

cwd = fileparts(mfilename('fullpath'));
run(fullfile(cwd, "../../setup.m"))

ref_path = gemini3d.fileio.expanduser(ref_path);
new_path = gemini3d.fileio.expanduser(new_path);

if isempty(time)
  assert(isfile(ref_path), "%s is not a file", ref_path)
  assert(isfile(new_path), "%s is not a file", new_path)
  A = gemini3d.read.frame(ref_path, "vars", name);
  B = gemini3d.read.frame(new_path, "vars", name);
  ref_path = fileparts(ref_path);
  new_path = fileparts(new_path);
else
  assert(isfolder(ref_path), "%s is not a directory", ref_path)
  assert(isfolder(new_path), "%s is not a directory", new_path)
  A = gemini3d.read.frame(ref_path, "time", time, "vars", name);
  B = gemini3d.read.frame(new_path, "time", time, "vars", name);
end

gemini3d.plot.diff(A.(name), B.(name), name, A.time, new_path, ref_path)

end
