function p = read_nml(path)

% for reading simulation config*.nml. Fortran namelist is a standard
% format.

narginchk(1,1)

filename = get_configfile(path);

p = read_nml_group(filename, 'base');
p.indat_file = absolute_path(p.indat_file);
p.indat_size = absolute_path(p.indat_size);
p.indat_grid = absolute_path(p.indat_grid);
if ~isfield(p, 'simdir')
  p.simdir = fileparts(p.indat_size);
end

if ~isfield(p, 'nml')
  p.nml = filename;
end

try %#ok<TRYNC>
p = merge_struct(p, read_nml_group(filename, 'setup'));
end
if isfield(p, 'eqdir')
  p.eqdir = absolute_path(p.eqdir);
end

if isfield(p, 'flagdneu') && p.flagdneu
  p = merge_struct(p, read_nml_group(filename, 'neutral_perturb'));
end
if ~isfield(p, 'mloc')
  p.mloc=[];
end

if isfield(p, 'flagprecfile') && p.flagprecfile
  p = merge_struct(p, read_nml_group(filename, 'precip'));
  p.prec_dir = absolute_path(p.prec_dir);
end

if isfield(p, 'flagE0file') && p.flagE0file
  p = merge_struct(p, read_nml_group(filename, 'efield'));
  p.E0_dir = absolute_path(p.E0_dir);
end

if isfield(p, 'flagglow') && p.flagglow
  p = merge_struct(p, read_nml_group(filename, 'glow'));
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