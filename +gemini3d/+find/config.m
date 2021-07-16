function filename = config(direc)
%% get configuration file
% if not found, errors
arguments
  direc (1,1) string {mustBeNonzeroLengthText}
end

import stdlib.fileio.expanduser

direc = expanduser(direc);

filename = string.empty;

if isfile(direc)
  filename = direc;
  return
end

if isfolder(direc)
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
end

if isempty(filename) || ~isfile(filename)
  error("find:config:FileNotFound", "could not find config file under %s", direc)
end

end % function


function filename = check_names(direc, names)
arguments
  direc (1,1) string {mustBeNonzeroLengthText}
  names (1,:) string {mustBeNonzeroLengthText}
end

filename = string.empty;

for s = names
  fn = fullfile(direc, s);
  if isfile(fn)
    filename = fn;
    return
  end
end

end

% Copyright 2020 Michael Hirsch

% Licensed under the Apache License, Version 2.0 (the "License");
% you may not use this file except in compliance with the License.
% You may obtain a copy of the License at

%     http://www.apache.org/licenses/LICENSE-2.0

% Unless required by applicable law or agreed to in writing, software
% distributed under the License is distributed on an "AS IS" BASIS,
% WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
% See the License for the specific language governing permissions and
% limitations under the License.
