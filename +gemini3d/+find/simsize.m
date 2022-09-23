function [simpath, ext] = simsize(apath)
%% find the path (directory, even if given filename) where simsize.* is
% also return the suffix
% the filename MUST be simsize.{h5,nc,dat}
arguments
  apath (1,1) string {mustBeNonzeroLengthText}
end

gemini3d.sys.check_stdlib()

apath = stdlib.fileio.expanduser(apath);

if isfile(apath)
  apath = fileparts(apath);
end

simpath = string.empty;
ext = string.empty;
suffix = ".h5";
% search all suffixes in case the inputs files are different from output
for stem = ["inputs", ""]
  simsize_fn = fullfile(apath, stem, "simsize") + suffix;
  if isfile(simsize_fn)
    simpath = fullfile(apath, stem);
    ext = suffix;
    return
  end
end


if isempty(simpath) || ~isfile(simpath)
  error("find:simsize:FileNotFound", "could not find simsize in %s", apath)
end

end % function
