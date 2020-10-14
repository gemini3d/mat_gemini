function last = path_tail(apath)
% get last part of directory path
% if filename, return filename with suffix
arguments
  apath (1,1) string
end

final = extractAfter(apath, strlength(apath)-1);
if final == "/" || final == "\"
  apath = extractBefore(apath, strlength(apath));
end

[~, name, ext] = fileparts(apath);

last = append(name, ext);

end % function
