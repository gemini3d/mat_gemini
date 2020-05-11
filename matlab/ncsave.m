function ncsave(filename, varname, A, dims, dtype)

narginchk(3, 5)

if nargin >= 4 && ~isempty(dims)
  for i = 2:2:length(dims)
    sizeA(i/2) = dims{i};
  end
else
  if isvector(A)
    sizeA = length(A);
  else
    sizeA = size(A);
  end
end
% coerce if needed
if nargin >= 5 && ~isempty(dtype)
  switch dtype
    case {'float64', 'double'}
      if ~isa(A, 'double')
        A = double(A);
      end
    case {'float32', 'single'}
      if ~isa(A, 'single')
        A = single(A);
      end
    otherwise, error('ncsave:type_error', 'unknown data type %s', dtype)
  end
end

vars = {};
if is_file(filename)
  vars = {ncinfo(filename).Variables.Name};
end

if any(strcmp(vars, varname))
  % existing variable
  % disp(['try ', varname])
  diskshape = ncinfo(filename, varname).Size;

  if all(diskshape == sizeA)
    ncwrite(filename, varname, A)
  elseif all(diskshape == fliplr(sizeA))
    ncwrite(filename, varname, A.')
  else
    error('ncsave:value_error', 'shape of %s does not match existing HDF5 shape %d %d %d %d  %d %d %d %d',varname, sizeA, diskshape)
  end
% catch excp
%   if any(strcmp(excp.identifier, {'MATLAB:imagesci:netcdf:unableToOpenFileforRead', 'MATLAB:imagesci:netcdf:unknownLocation'}))
%     % pass Matlab
%   elseif any(strcmp(excp.message, {'No such file or directory', 'NetCDF: Variable not found'}))
%     % pass Octave
%   else
%     disp(['failed create ', varname])
%     rethrow(excp)
%   end
else
  % disp(['create ', varname])
  % new variable
  if isscalar(A)
    nccreate(filename, varname, 'Datatype', class(A))
  elseif length(sizeA) >= 1 && length(sizeA) < 3
    nccreate(filename, varname, 'Dimensions', dims, 'Datatype', class(A))
  else
    % enable Gzip compression--remember Matlab's dim order is flipped from
    % C / Python
    switch length(sizeA)
      case 4, chunksize = [sizeA(1), sizeA(2), 1, sizeA(4)];
      case 3, chunksize = [sizeA(1), sizeA(2), 1];
      otherwise, error('ncsave:fixme', '%s is bigger than 4 dims', varname)
    end
    % "Datatype" to be Octave case-sensitive keyword compatible
    nccreate(filename, varname, 'Dimensions', dims, ...
      'Datatype', class(A)) %, ...
      %'DeflateLevel', 1, 'Shuffle', true, 'ChunkSize', chunksize)
  end
  ncwrite(filename, varname, A)
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
