function isabs = is_absolute_path(apath)
%% true if path is absolute. Path need not yet exist.
% even if path has inside ".." it's still considered absolute
% e.g. Python
%  os.path.isabs("/foo/../bar") == True

arguments
  apath string
end

apath = gemini3d.fileio.expanduser(apath);

if ispc
  hasDrive = cell2mat(isstrprop(extractBefore(apath, 2), "alpha", "ForceCellOutput", true));
  isabs = hasDrive & extractBetween(apath,2,2) == ":" & ...
                   (extractBetween(apath,3,3) == "/" | extractBetween(apath,3,3) == "\");
else
  isabs = startsWith(apath, "/");
end

end % function
