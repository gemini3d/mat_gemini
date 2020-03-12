%!assert(memfree() > 0)
%!assert(isnumeric(memfree))
function freebytes = memfree()
%% find free physical RAM on Windows (with or without Cygwin) and Linux systems
% currently Matlab doesn't support memory() on Linux/Mac systems
% This function is meant to give free memory using Matlab or Octave
%
% It demonstrates using Python from Matlab or GNU Octave seamlessly.
%
% Output:
% --------
% free physical RAM [bytes]
%
% If Python psutils not available, returns NaN
%
% Michael Hirsch, Ph.D.

try
  freebytes = double(py.psutil.virtual_memory().available);
catch
  [~,freebytes] = system('python -c "import psutil; print(psutil.virtual_memory().available)"');
  freebytes = str2double(freebytes);
end

end %function


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