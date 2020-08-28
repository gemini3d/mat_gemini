function p = read_config(path)
% reads simulation configuration into struct
arguments
  path (1,1) string
end

filename = gemini3d.get_configfile(path);

[~,~,ext] = fileparts(filename);

switch lower(ext)
  case '.nml', p = gemini3d.read_nml(filename);
  case '.ini', p = gemini3d.read_ini(filename);
  otherwise, error('read_config:value_error', 'config file type unknown: %s', filename)
end

t0 = datetime(p.ymd(1), p.ymd(2), p.ymd(3)) + seconds(p.UTsec0);
p.times = t0:seconds(p.dtout):(t0 + seconds(p.tdur));

%% deduce data file format from simsize format
% needs to be here and in read_nml
if ~isfield(p, 'file_format')
  [~,~,ext] = fileparts(p.indat_size);
  p.file_format = extractAfter(ext, 1);
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
