function h5save(filename, varname, A, sizeA, dtype)
% H5SAVE
% create or append to HDF5 file
% parent folder (file directory) must already exist
arguments
  filename (1,1) string
  varname (1,1) string
  A {mustBeNumeric,mustBeNonempty}
  sizeA (1,:) {mustBeInteger,mustBeNonnegative} = []
  dtype (1,1) string = ""
end

filename = gemini3d.fileio.expanduser(filename);

if isempty(sizeA)
  if isvector(A)
    sizeA = length(A);
  else
    sizeA = size(A);
  end
end
% coerce if needed
if dtype ~= ""
  A = gemini3d.fileio.coerce_ds(A, dtype);
end
if ischar(A)
  A = string(A);
  sizeA = size(A);
end

if isfile(filename) && gemini3d.fileio.h5exists(filename, varname)
  exist_file(filename, varname, A, sizeA)
else
  new_file(filename, varname, A, sizeA)
end

end % function


function exist_file(filename, varname, A, sizeA)

diskshape = gemini3d.fileio.h5size(filename, varname);
if length(diskshape) >= 2
  % start is always a row vector, regardless of shape of array
  start = ones(1,ndims(A));
elseif ~isempty(diskshape)
  start = 1;
end

if isscalar(A)
  h5write(filename, varname, A)
elseif all(diskshape == sizeA)
  h5write(filename, varname, A, start, sizeA)
elseif all(diskshape == fliplr(sizeA))
  h5write(filename, varname, A.', start, fliplr(sizeA))
else
  error('h5save:value_error', ['shape of ',varname,': ', int2str(sizeA), ' does not match existing HDF5 shape ', int2str(diskshape)])
end

end % function


function new_file(filename, varname, A, sizeA)

folder = fileparts(filename);
assert(isfolder(folder), '%s is not a folder, cannot create %s', folder, filename)

if isvector(A)
  h5create(filename, varname, sizeA, 'DataType', class(A))
else
  % enable Gzip compression--remember Matlab's dim order is flipped from
  % C / Python
  h5create(filename, varname, sizeA, 'DataType', class(A), ...
    'Deflate', 1, 'Fletcher32', true, 'Shuffle', true, ...
    'ChunkSize', gemini3d.fileio.auto_chunk_size(sizeA))
end % if

h5write(filename, varname, A)

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
