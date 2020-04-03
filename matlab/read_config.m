function p = read_config(path)
% reads simulation configuration into struct
narginchk(1,1)

filename = get_configfile(path);

[~,~,ext] = fileparts(filename);

switch ext
  case '.nml', p = read_nml(filename);
  case '.ini', p = read_ini(filename);
  otherwise, error(['not sure how to read config file ', filename])
end

%% deduce data file format from simsize format
[~,~,ext] = fileparts(p.indat_size);
p.file_format = ext(2:end);

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