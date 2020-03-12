%!assert(islogical(isoctave))
%!assert(isoctave)
function isoct = isoctave()
persistent oct;

if isempty(oct)
    oct = exist('OCTAVE_VERSION', 'builtin') == 5;
end

isoct=oct; % has to be a separate line/variable for matlab

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