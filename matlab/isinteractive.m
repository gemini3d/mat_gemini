%!assert(islogical(isinteractive))
function isinter = isinteractive()
%% tell if the program is being run interactively or not.

persistent inter;

if isempty(inter)
  if isoctave
    inter = isguirunning;
  else
    % matlab, this test doesn't work for Octave
    % don't use batchStartupOptionUsed as it neglects the "-nodesktop" case
    inter = usejava('desktop');
  end
end

% has to be a separate line / variable for matlab
isinter=inter;

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