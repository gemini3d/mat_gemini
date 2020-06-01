%!assert(ischar(absolute_path('~')))
function abspath = absolute_path(path)
% path need not exist, but absolute path is returned
%
% NOTE: some network file systems are not resolvable by Matlab Java
% subsystem, but are sometimes still valid--so we warn and return
% unmodified path if this occurs.
%
% NOTE: GNU Octave is weaker at this.
% example input: /foo/bar/../baz
% if "bar" doesn't exist, make_absolute_filename() may just return the input unmodified.

narginchk(1,1)

% have to expand ~ first
path = expanduser(path);

if isoctave
  abspath = make_absolute_filename(path);
else
  if is_relative_path(path)
    % TODO: handle .file or .path/.file
    path = fullfile(pwd, path);
  end
  try
    abspath = char(java.io.File(path).getCanonicalPath());
  catch
    % fprintf(2, 'could not make absolute path from %s\n', path)
    abspath = path;
  end
end

% debugging
% disp([path, ' => ',abspath])

end % function

% Copyright 2020 Michael Hirsch, Ph.D.

% Licensed under the Apache License, Version 2.0 (the "License");
% you may not use this file except in compliance with the License.
% You may obtain a copy of the License at

%     http://www.apache.org/licenses/LICENSE-2.0

% Unless required by applicable law or agreed to in writing, software
% distributed under the License is distributed on an "AS IS" BASIS,
% WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
% See the License for the specific language governing permissions and
% limitations under the License.
