function lxs = simsize(path)

narginchk(1,1)

[path, ext] = get_simsize_path(path);

switch ext
  case '.h5'
    lxs = read_h5(path);
  case '.nc'
    lxs = read_nc(path);
  case '.dat'
    lxs = read_raw(path);
  otherwise, error('simsize:value_error', 'unknown simsize file type %s', fn)
end

lxs = lxs(:).';  % needed for concatenation

end % function


function lxs = read_h5(path)

fn=fullfile(path, 'simsize.h5');

if isoctave

  d = load(fn);
  if isfield(d, 'lxs')
    lxs = d.lxs;
  elseif isfield(d, 'lx')
    lxs = d.lx;
  elseif isfield(d, 'lx1')
    % octave bug: octave_base_value::int32_scalar_value(): wrong type argument 'int32 matrix'
    lxs = [d.lx1; d.lx2; d.lx3];
  else
    error('simsize:lookup_error', 'did not find lxs, lx, lx1 in %s', fn)
  end

else

  varnames = h5variables(fn);

  if any(strcmp('lxs', varnames))
    lxs = h5read(fn, '/lxs');
  elseif any(strcmp('lx', varnames))
    lxs = h5read(fn, '/lx');
  elseif any(strcmp('lx1', varnames))
    lxs = [h5read(fn, '/lx1'), h5read(fn, '/lx2'), h5read(fn, '/lx3')];
  else
    error('simsize:lookup_error', 'did not find lxs, lx, lx1 in %s', fn)
  end

end

end % function


function lxs = read_nc(path)

% use temporary variable to be R2017b OK
fn = fullfile(path, 'simsize.nc');

varnames = ncvariables(fn);

if any(strcmp('lxs', varnames))
  lxs = ncread(fn, '/lxs');
elseif any(strcmp('lx', varnames))
  lxs = h5read(fn, '/lx');
elseif any(strcmp('lx1', varnames))
  lxs = [ncread(fn, '/lx1'), ncread(fn, '/lx2'), ncread(fn, '/lx3')];
end

end % function


function lxs = read_raw(path)

fid = fopen(fullfile(path, 'simsize.dat'), 'r');
lxs = fread(fid, 3, 'integer*4');
fclose(fid);

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
