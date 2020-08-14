%!assert(ischar(absolute_path('~')))
function abspath = absolute_path(path)
% path need not exist, but absolute path is returned
%
% NOTE: some network file systems are not resolvable by Matlab Java
% subsystem, but are sometimes still valid--so return
% unmodified path if this occurs.
%
% NOTE: GNU Octave is weaker at this.
% example input: /foo/bar/../baz
% if "bar" doesn't exist, make_absolute_filename() may just return the input unmodified.
%
% Copyright (c) 2020 Michael Hirsch (MIT License)

import gemini3d.fileio.*

narginchk(1,1)

% have to expand ~ first
path = expanduser(path);

if ~is_absolute_path(path)
  % otherwise the default is Documents/Matlab, which is probably not wanted.
  path = fullfile(pwd, path);
end

if ~usejava('jvm')
  abspath = path;
  return
end

try
  abspath = char(java.io.File(path).getCanonicalPath());
catch
  abspath = path;
end

end % function
