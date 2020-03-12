%!assert(ischar(expanduser('~')))
function expanded = expanduser(p)
% expanded = expanduser(path)
%
%   expands tilde ~ into user home directory for Matlab and GNU Octave.
%
%   Useful for Matlab functions like h5read() and some Computer Vision toolbox functions
%   that can't handle ~ and Matlab does not consider it a bug per conversations with
%   Mathworks staff
%
%   See also absolute_path

narginchk(1,1)
validateattributes(p, {'char'}, {'vector'})

%% GNU Octave
if isoctave
  expanded = tilde_expand(p);
  return
end

%% Matlab >= R2014b
try %#ok<TRYNC>
  expanded = char(py.pathlib.Path(p).expanduser());
  return
end

%% Matlab < R2014b
expanded = p;
if strcmp(expanded(1), '~')
  expanded = [homepath(), expanded(2:end)];
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