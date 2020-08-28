function isabs = is_absolute_path(p)
%% true if path is absolute. Path need not yet exist.
arguments
  p (1,1) string
end

p = gemini3d.fileio.expanduser(p);
% Must expanduser() before Java

if usejava('jvm')
  isabs = java.io.File(p).isAbsolute();
elseif ispc
  p = char(p);
  isabs = isletter(p(1)) && strcmp(p(2), ':') && any(strcmp(p(3), ["/", "\"]));
else
  isabs = startsWith(p, "/");
end

end % function
