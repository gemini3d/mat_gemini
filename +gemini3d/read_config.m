function cfg = read_config(direc)
% reads simulation configuration into struct
% returns struct.empty if config file doesn't exist
arguments
  direc (1,1) string
end

filename = gemini3d.find.config(direc);

if endsWith(filename, ".ini", 'IgnoreCase', true)
  cfg = read_ini(filename);
else
  cfg = read_nml(filename);
end

if isempty(cfg)
  return
end

t0 = datetime(cfg.ymd(1), cfg.ymd(2), cfg.ymd(3)) + seconds(cfg.UTsec0);
cfg.times = t0:seconds(cfg.dtout):(t0 + seconds(cfg.tdur));

%% deduce data file format from simsize format
% needs to be here and in read_nml
if ~isfield(cfg, 'file_format')
  [~,~,ext] = fileparts(cfg.indat_size);
  cfg.file_format = extractAfter(ext, 1);
end

end % function

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
