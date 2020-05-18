function p = read_nml(path)

% for reading simulation config*.nml. Fortran namelist is a standard
% format.

narginchk(1,1)

filename = get_configfile(path);

%% required groups
p = read_nml_group(filename, 'base');
p = merge_struct(p, read_nml_group(filename, 'flags'));
p = merge_struct(p, read_nml_group(filename, 'files'));
p.indat_file = absolute_path(p.indat_file);
p.indat_size = absolute_path(p.indat_size);
p.indat_grid = absolute_path(p.indat_grid);
%% deduce data file format from simsize format
if ~isfield(p, 'file_format')
  [~,~,ext] = fileparts(p.indat_size);
  p.file_format = ext(2:end);
end

%% optional groups
if ~isfield(p, 'simdir')
  % assumes that simsize.* are always under foo/inputs/
  p.simdir = absolute_path(fileparts(p.indat_size));
end

if ~isfield(p, 'nml')
  p.nml = filename;
end

p = read_if_present(p, filename, 'setup');
if isfield(p, 'eqdir')
  p.eqdir = absolute_path(p.eqdir);
end

read_if_present(p, filename, 'neutral_perturb');
if ~isfield(p, 'mloc')
  p.mloc=[];
end

p = read_if_present(p, filename,  'precip');
if isfield(p, 'prec_dir')
  p.prec_dir = absolute_path(p.prec_dir);
end

p = read_if_present(p, filename, 'efield');
if isfield(p, 'E0_dir')
  p.E0_dir = absolute_path(p.E0_dir);
end

p = read_if_present(p, filename, 'glow');

end % function

function p = read_if_present(p, filename, group)
narginchk(3, 3)

try
  p = merge_struct(p, read_nml_group(filename, group));
catch excp
  if ~strcmp(excp.identifier, 'read_nml_group:group_not_found')
    rethrow(excp)
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
