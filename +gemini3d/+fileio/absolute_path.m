function abspath = absolute_path(p)
% path need not exist, but absolute path is returned
%
% NOTE: some network file systems are not resolvable by Matlab Java
% subsystem, but are sometimes still valid--so return
% unmodified path if this occurs.
%
% Copyright (c) 2020 Michael Hirsch (MIT License)
arguments
  p (1,1) string
end

% have to expand ~ first
p = gemini3d.fileio.expanduser(p);

if ~gemini3d.fileio.is_absolute_path(p)
  % otherwise the default is Documents/Matlab, which is probably not wanted.
  p = fullfile(pwd, p);
end

abspath = p;

try %#ok<TRYNC>
  abspath = string(java.io.File(p).getCanonicalPath());
end

end % function
