function file = simsize(apath, suffix)
%% return full path where simsize.h5 is
arguments
  apath (1,1) string {mustBeNonzeroLengthText}
  suffix (1,1) string {mustBeNonzeroLengthText} = ".h5"
end

gemini3d.sys.check_stdlib()

apath = stdlib.fileio.expanduser(apath);

file = string.empty;

if isfile(apath)
  [d, n] = fileparts(apath);
  if n == "simsize"
    file = apath;
    return
  end

  apath = d;
end

if ~isfolder(apath)
  return
end

for stem = ["inputs", ""]
  n = fullfile(apath, stem, "simsize" + suffix);
  if isfile(n)
    file = n;
    return
  end
end

end % function
