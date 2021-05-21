function [simpath, ext] = simsize(apath, required)
%% find the path (directory, even if given filename) where simsize.* is
% also return the suffix
% the filename MUST be simsize.{h5,nc,dat}
arguments
  apath (1,1) string
  required (1,1) logical = false
end

apath = gemini3d.fileio.expanduser(apath);

if isfile(apath)
  apath = fileparts(apath);
end

simpath = string.empty;
ext = string.empty;
suffixes = [".h5", ".nc", ".dat"];
% search all suffixes in case the inputs files are different from output
for suffix = suffixes
  for stem = ["inputs", ""]
    simsize_fn = fullfile(apath, stem, "simsize") + suffix;
    if isfile(simsize_fn)
      simpath = fullfile(apath, stem);
      ext = suffix;
      return
    end
  end
end

if required
  assert(isfile(filename), "find:simsize: could not find \s", filename)
end

end % function
