function h5save(filename, varname, A, sizeA, dtype)

narginchk(3, 5)

if nargin < 4 || isempty(sizeA)
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
    otherwise, error('h5save:type_error', 'unknown data type %s', dtype)
  end
end

filename = absolute_path(filename);
% allows ~/data/foo.h5

try
  % existing variable
  diskshape = h5info(filename, varname).Dataspace.Size;
  if length(diskshape) >= 2
     % start is always a row vector, regardless of shape of array
      start = ones(1,ndims(A));
  else
    start = 1;
  end

  if all(diskshape == sizeA)
    h5write(filename, varname, A, start, sizeA)
  elseif all(diskshape == fliplr(sizeA))
    h5write(filename, varname, A.', start, fliplr(sizeA))
  else
    error('h5save:value_error', 'shape of %s does not match existing HDF5 shape %d %d %d %d  %d %d %d %d',varname, sizeA, diskshape)
  end
catch excp % new variable
  if ~any(strcmp(excp.identifier, {'MATLAB:imagesci:h5info:fileOpenErr', 'MATLAB:imagesci:h5info:unableToFind'}))
    rethrow(excp)
  end

  if ~ismatrix(A)
    % enable Gzip compression--remember Matlab's dim order is flipped from
    % C / Python
    switch ndims(A)
      case 4, chunksize = [sizeA(1), sizeA(2), 1, sizeA(4)];
      case 3, chunksize = [sizeA(1), sizeA(2), 1];
      otherwise, error('h5save:fixme', '%s is bigger than 4 dims', varname)
    end
    h5create(filename, varname, sizeA, 'DataType', class(A), ...
      'Deflate', 1, 'Fletcher32', true, 'Shuffle', true, 'ChunkSize', chunksize)
  else
    h5create(filename, varname, sizeA, 'DataType', class(A))
  end
  h5write(filename, varname, A)
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
