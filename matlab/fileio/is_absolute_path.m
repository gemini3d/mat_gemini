function isrel = is_absolute_path(path)
%% true if path is absolute. Path need not yet exist.

narginchk(1,1)

path = expanduser(path);
% both matlab and octave need expanduser

if isoctave
  isrel = is_absolute_filename(path);
else
  isrel = java.io.File(path).isAbsolute();
end

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
