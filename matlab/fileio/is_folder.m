%!assert(islogical(is_folder))
%!test ~is_folder('0984yr09uj8yfeaas918whfe98h41phfoiSDVarasAf8da1jflasjfdsdf');
%!test is_folder('.');

function ret = is_folder(path)
% overloading doesn't work in Octave since it is a core *library* function
% there doesn't appear to be a solution besides renaming this function.
narginchk(1,1)

path = expanduser(path);

if exist('isfolder', 'builtin') == 5 || exist('isfolder', 'file') == 2
  ret = isfolder(path);
else
  ret = exist(path, 'dir') == 7;
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
