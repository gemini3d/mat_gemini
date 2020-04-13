function filename = get_configfile(path)
%% get configuration file

narginchk(1,1)

% necessary for Matlab
path = absolute_path(path);

if is_file(path)
  filename = path;
elseif is_folder(path)
  names = {'config.nml', 'inputs/config.nml', 'config.ini', 'inputs/config.ini'};
  for s = names
    filename = [path, filesep, s{:}];
    if is_file(filename)
      break
    end
  end
else
  error(['could not find config file in ', path])
end

assert(is_file(filename), ['could not find config file in ', path])

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
