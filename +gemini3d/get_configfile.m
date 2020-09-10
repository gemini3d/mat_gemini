function filename = get_configfile(direc)
%% get configuration file
arguments
  direc string
end

direc = gemini3d.fileio.expanduser(direc);

if isfile(direc)
  filename = direc;
  return
elseif isfolder(direc)
  names = ["config.nml", "inputs/config.nml", "config.ini", "inputs/config.ini"];
  filename = check_names(direc, names);
  if isfile(filename)
    return
  end

  files = dir(fullfile(direc, "inputs/config*.nml"));
  filename = check_names(fullfile(direc, "inputs"), {files.name});

  if ~isfile(filename)
    files = dir(fullfile(direc, "config*.nml"));
    filename = check_names(direc, {files.name});
  end
else
  error('get_configfile:file_not_found', 'could not find %s', direc)
end

if ~isfile(filename)
  error('get_configfile:file_not_found', 'could not find config.nml under %s', direc)
end

end % function


function filename = check_names(direc, names)

for s = names
  filename = fullfile(direc, s);
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
