function filename = config(direc)
%% get configuration file
arguments
  direc {mustBeTextScalar}
end

gemini3d.sys.check_stdlib()

direc = stdlib.expanduser(direc);

filename = string.empty;

if isfile(direc)
  filename = direc;
  return
end

if ~isfolder(direc)
  return
end

names = ["config.nml", "inputs/config.nml"];
filename = check_names(direc, names);
if ~isempty(filename)
  return
end

for p = ["inputs/config*.nml", "config*.nml"]
  files = dir(fullfile(direc, p));
  filename = check_names(p, {files.name});
  if ~isempty(filename)
    return
  end
end

end % function


function filename = check_names(direc, names)
arguments
  direc (1,1) string {mustBeNonzeroLengthText}
  names (1,:) string {mustBeNonzeroLengthText}
end

filename = string.empty;

for s = names
  fn = stdlib.join(direc, s);
  if isfile(fn)
    filename = fn;
    return
  end
end

end
