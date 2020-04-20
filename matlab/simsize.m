function lxs = simsize(path)

narginchk(1,1)

fn = [];
if is_file(path)
  [~, stem, ext] = fileparts(path);
  if strcmp(stem, 'simsize')
    fn = path;
  else
    if strcmp(stem, 'inputs')
      part = '/simsize';
    else
      part = '/inputs/simsize';
    end
    fn = [fileparts(path),part, ext];
  end
elseif is_folder(path)
  for ext = {'.h5', '.nc', '.dat'}
    fn = [path, '/simsize',ext{:}];
    if is_file(fn)
      break
    end
  end
end

assert(is_file(fn), [fn,' is not a file.'])
[~,~,ext] = fileparts(fn);

switch ext
  case '.h5'
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
        error(['did not find lxs, lx, lx1 in ', fn])
      end
    else
      % use temporary variable to be R2017b OK
      finf = h5info(fn);
      ds = finf.Datasets;
      varnames = {ds(:).Name};

      if any(strcmp('lxs', varnames))
        lxs = h5read(fn, '/lxs');
      elseif any(strcmp('lx', varnames))
        lxs = h5read(fn, '/lx');
      elseif any(strcmp('lx1', varnames))
        lxs = [h5read(fn, '/lx1'), h5read(fn, '/lx2'), h5read(fn, '/lx3')];
      else
        error(['did not find lxs, lx, lx1 in ', fn])
      end
    end
  case '.nc'
    % use temporary variable to be R2017b OK
    finf = ncinfo(fn);
    varnames = extractfield(finf.Variables, 'Name');

    if any(strcmp('lxs', varnames))
      lxs = ncread(fn, '/lxs');
    elseif any(strcmp('lx', varnames))
        lxs = h5read(fn, '/lx');
    elseif any(strcmp('lx1', varnames))
      lxs = [ncread(fn, '/lx1'), ncread(fn, '/lx2'), ncread(fn, '/lx3')];
    end
  case '.dat'
    fid = fopen(fn, 'r');
    lxs = fread(fid, 3, 'integer*4');
    fclose(fid);
  otherwise, error(['unknown simsize file type ',fn])
end

lxs = lxs(:).';  % needed for concatenation

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
