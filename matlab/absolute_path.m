%!assert(ischar(absolute_path('~')))
function abspath = absolute_path(path)
% path need not exist, but absolute path is returned
%
% NOTE: GNU Octave is weaker at this, especially if /foo/bar/../baz and "bar"
% doesn't exist, it may just return the input unmodified.

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
  catch exc
    error('absolute_path:value_error', 'could not make absolute path from %s', path)
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
