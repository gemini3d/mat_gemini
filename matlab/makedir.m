function makedir(path)
%% malformed paths can be "created" but are not accessible.
% This function workaround that bug in Matlab mkdir().
%
narginchk(1,1)

path = absolute_path(path);

if ~is_folder(path)
  mkdir(path);
end

if ~is_folder(path)
  error('makedir:not_a_directory %s', path)
end

end


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
