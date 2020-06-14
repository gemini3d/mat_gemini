function names = get_testnames(topdir, only)
narginchk(1,2)

if nargin < 2, only = []; end

names = {};
j = 1;
dirs = dir(topdir);
for i = 1:length(dirs)
  if dirs(i).isdir && length(dirs(i).name) > 2
    [~, name] = fileparts(dirs(i).name);
    if ~isempty(only) && isempty(strfind(name, only))
      continue
    end
    names{j} = name; %#ok<AGROW>
    j = j+1;
  end
end

end % function