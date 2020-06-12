function last = path_tail(direc)
% get last part of directory path
% if filename, return filename with suffix
narginchk(1, 1)
validateattributes(direc, {'char'}, {'vector'})

direc = strrep(direc, '\', '/');
% this breaks for escaped spaces "\ "

parts = strsplit(direc, '/');
if isempty(parts{end})
  last = parts{end-1};
else
  last = parts{end};
end

assert(~isempty(last), 'could not find last part of %s', direc)

end % function
