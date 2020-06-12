function generate_reference_plots(topdir, only)

narginchk(1,2)

if nargin < 2, only = []; end

names = get_testnames(topdir, only);

for i = 1:length(names)
  plotall(fullfile(topdir, names{i}), 'png')
end

end % function
