function cfg = config(direc)
% reads simulation configuration into struct
arguments
  direc (1,1) string {mustBeNonzeroLengthText}
end

cfg = read_nml(direc);

if isempty(cfg)
  return
end

t0 = datetime(cfg.ymd(1), cfg.ymd(2), cfg.ymd(3)) + seconds(cfg.UTsec0);
cfg.times = t0:seconds(cfg.dtout):(t0 + seconds(cfg.tdur));

%% if a GLOW sim
if isfield(cfg, "dtglow")
  if ~isfield(cfg, "aurmap_dir")
    % DEPRECATED: for old hard-coded sims
    cfg.aurmap_dir = "aurmaps";
  end
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
