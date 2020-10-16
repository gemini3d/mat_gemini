function s1 = merge_struct(s1, s2, overwrite)
%% merge_struct(struct, s)
%
% merges fields of SCALAR structs "s1" and "s2", optionally overwriting existing
% s1 fields from s2.
arguments
  s1 (1,1) struct
  s2 (1,1) struct
  overwrite (1,1) logical = false
end

s1fields = fieldnames(s1);
for field = fieldnames(s2)'
  if ~overwrite && isfield(s1fields, field{:})
    error('merge_struct:value_error', 'not overwriting field %s', field{:})
  end
  s1.(field{:}) = s2.(field{:});
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
