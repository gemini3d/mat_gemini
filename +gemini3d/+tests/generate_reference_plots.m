function generate_reference_plots(topdir, only)
arguments
  topdir (1,1) string
  only (1,:) string = string.empty
end

topdir = gemini3d.fileio.expanduser(topdir);

names = get_testnames(topdir, only);

assert(~isempty(names), "did not find any data under %s", topdir)

for n = names
  gemini3d.plot(fullfile(topdir, n), "png")
end

end % function
