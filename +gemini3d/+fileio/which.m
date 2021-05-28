function exe = which(name, fpath)
%gemini3d.find.which Find executable with name under path

arguments
  name string
  fpath string = string.empty
end

assert(length(name) < 2, "fileio.which is for one executable at a time")

name = exe_name(name);

fpath = fpath(strlength(fpath)>0);  % sanitize user ""

if gemini3d.fileio.is_absolute_path(name)
  if isfile(name)
    exe = name;
    return
  end

  % use full path as hint
  [fp,name,ext] = fileparts(name);
  name = name + ext;
  if isempty(fpath)
    fpath = fp;
  end
end

% name not an absolute path, so search for exe
exe = string.empty;

btype = ["", "Release", "RelWithDebInfo", "Debug"];

if isempty(fpath)
  fpath = getenv('PATH');
end

fpath = gemini3d.fileio.expanduser(fpath);
fpath = split(string(fpath), pathsep).';
fpath = fpath(strlength(fpath)>0);

for p = fpath

  for b = btype
    e = fullfile(p, b, name);
    if isfile(e)
      [ok1, stat] = fileattrib(e);
      if ok1 && (stat.UserExecute == 1 || stat.GroupExecute == 1)
        exe = e;
        return
      end
    end
  end

end

end
