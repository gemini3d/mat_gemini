function filename = get_configfile(path)
%% get configuration file

narginchk(1,1)

path = gemini3d.fileio.expanduser(path);

if isfile(path)
  filename = path;
elseif isfolder(path)
  names = {'config.nml', 'inputs/config.nml', 'config.ini', 'inputs/config.ini'};
  filename = check_names(path, names);

  if ~isfile(filename)
    files = dir(fullfile(path, 'inputs/config*.nml'));
    filename = check_names(fullfile(path, 'inputs'), {files.name});
  end

  if ~isfile(filename)
    files = dir(fullfile(path, 'config*.nml'));
    filename = check_names(path, {files.name});
  end
else
  error('get_configfile:file_not_found', 'could not find %s', path)
end

if ~isfile(filename)
  error('get_configfile:file_not_found', 'could not find config.nml under %s', path)
end

end % function


function filename = check_names(path, names)

narginchk(2,2)
validateattributes(path, {'char'}, {'vector'})
assert(iscell(names), 'names is a cell vector of filenames')

filename = '';

for s = names
  filename = fullfile(path, s{:});
  if isfile(filename)
    break
  end
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
