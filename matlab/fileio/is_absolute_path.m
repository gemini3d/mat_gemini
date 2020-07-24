function isrel = is_absolute_path(path)
%% true if path is absolute. Path need not yet exist.

narginchk(1,1)

path = expanduser(path);
% both matlab and octave need expanduser

if isoctave
  isrel = is_absolute_filename(path);
elseif usejava('jvm')
  isrel = java.io.File(path).isAbsolute();
elseif ispc
  isrel = isletter(path(1)) && strcmp(path(2), ':') && any(strcmp(path(3), ['/', '\']));
else
  isrel = strcmp(path(1), '/');
end

end % function
