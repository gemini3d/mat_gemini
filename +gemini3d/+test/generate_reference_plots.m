function generate_reference_plots(topdir, only)
arguments
  topdir (1,1) string
  only (1,:) string = string.empty
end

import stdlib.fileio.expanduser

topdir = expanduser(topdir);

names = get_testnames(topdir, only);

mustBeNonempty(names)

for n = names
  gemini3d.plot(fullfile(topdir, n), "png")
end

end % function
