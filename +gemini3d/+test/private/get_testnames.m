
function names = get_testnames(topdir, only)
% get test names contained in only, if specified
%
% Parameters
% only: string or string array

arguments
  topdir (1,1) string
  only (1,:) string = string.empty
end

names = string.empty;
j = 1;
dirs = dir(stdlib.expanduser(topdir));
for i = 1:length(dirs)
  if dirs(i).isdir && length(dirs(i).name) > 2
    [~, name] = fileparts(dirs(i).name);
    if isempty(only) || contains(name, only)
      names(j) = string(name);
      j = j+1;
    end
  end
end

end % function
