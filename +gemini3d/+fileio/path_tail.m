function last = path_tail(direc)
% get last part of directory path
% if filename, return filename with suffix
arguments
  direc (1,1) string
end

direc = strrep(direc, '\', '/');
% this breaks for escaped spaces "\ "

parts = strsplit(direc, '/');
if parts{end} == ""
  last = parts{end-1};
else
  last = parts{end};
end

assert(last ~= "", 'could not find last part of %s', direc)

last = string(last);

end % function
