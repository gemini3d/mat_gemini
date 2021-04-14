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
  time datetime = datetime.empty
end

if isempty(time)
  A = gemini3d.read.frame(ref_path, "vars", name);
  B = gemini3d.read.frame(new_path, "vars", name);
else
  A = gemini3d.read.frame(ref_path, "time", time, "vars", name);
  B = gemini3d.read.frame(new_path, "time", time, "vars", name);
end

assert(~isempty(A), "failed to read reference %s from %s", name, ref_path)
assert(~isempty(B), "failed to read new %s from %s", name, new_path)

gemini3d.plot.diff(A.(name), B.(name), name, A.time, new_path, ref_path)

end
