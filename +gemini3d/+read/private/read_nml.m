function p = read_nml(apath)
% for reading simulation config*.nml.
% Fortran namelist is a standard format.
%
% returns struct.empty if file not found
arguments
  apath (1,1) string {mustBeNonzeroLengthText}
end

fn = gemini3d.find.config(apath);
assert(~isempty(fn), "Invalid simulation directory: no simulation config file config.nml found in " + fn)

%% required namelists
p = read_namelist(fn, 'base');

p = merge_struct(p, read_namelist(fn, 'flags'));
p = merge_struct(p, read_namelist(fn, 'files'));

%% optional namelists
if ~isfield(p, 'nml')
  p.nml = fn;
end

p = read_if_present(p, fn, 'setup');
if isfield(p, 'eqdir')
  p.eq_dir = p.eqdir;
end

if isfield(p, 'setup_functions')
  if ischar(p.setup_functions)
    p.setup_functions = string({p.setup_functions});
  end
end

%% neutral_perturb
p = read_if_present(p, fn, 'neutral_perturb');

if ~isfield(p, 'sourcemlat'), p.sourcemlat = []; end
if ~isfield(p, 'sourcemlon'), p.sourcemlon = []; end

%% neutral_BG
p = read_if_present(p, fn, 'neutral_BG');

%% precip
p = read_if_present(p, fn,  'precip');
% don't make prec_dir absolute here, to respect upcoming p.outdir

p = read_if_present(p, fn, 'efield');
% don't make E0_dir absolute here, to respect upcoming p.outdir

p = read_if_present(p, fn, 'glow');

p = read_if_present(p, fn, 'milestone');

end % function

function p = read_if_present(p, fn, namelist)
% read a namelist, if it exists, otherwise don't modify the input struct

try
  p = merge_struct(p, read_namelist(fn, namelist));
catch excp
  if ~strcmp(excp.identifier, 'read_namelist:namelist_not_found')
    rethrow(excp)
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
