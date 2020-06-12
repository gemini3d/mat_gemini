function names = get_testnames(topdir, only)
narginchk(1,2)

if nargin < 2, only = []; end

if isempty(only)
  found = dir(topdir);
else
  found = dir(fullfile(topdir, ['*', only, '*']));
end

names = {};
j = 0;
for i = 1:size(found)
  if found(i).isdir && length(found(i).name) > 2
    j = j+1;
    [~, name] = fileparts(found(i).name);
    names{j} = name; %#ok<AGROW>
  end
end

end % function