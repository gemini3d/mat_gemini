function names = get_testnames(topdir, only)
% get test names contained in only, if specified
%
% Parameters
% only: string or string array
%
narginchk(1,2)

if nargin < 2, only = {}; end

names = {};
j = 1;
dirs = dir(topdir);
for i = 1:length(dirs)
  if dirs(i).isdir && length(dirs(i).name) > 2
    [~, name] = fileparts(dirs(i).name);
    if isempty(only) || contains(name, only)
      names{j} = name; %#ok<AGROW>
      j = j+1;
    end
  end
end

end % function