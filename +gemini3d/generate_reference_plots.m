function generate_reference_plots(topdir, only)

narginchk(1,2)

if nargin < 2, only = []; end

names = gemini3d.get_testnames(topdir, only);

for i = 1:length(names)
  gemini3d.vis.plotall(fullfile(topdir, names{i}), 'png')
end

end % function
