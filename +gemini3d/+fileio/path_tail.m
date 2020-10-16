function last = path_tail(apath)
% get last part of directory path
% if filename, return filename with suffix
arguments
  apath string
end

final = extractAfter(apath, strlength(apath)-1);

i = final == "/" | final == "\";

apath(i) = extractBefore(apath(i), strlength(apath(i)));

[~, name, ext] = fileparts(apath);

last = append(name, ext);

end % function
