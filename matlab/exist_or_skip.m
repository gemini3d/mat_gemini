function exist_or_skip(filename, path_type)
% if paths not exist, exit code 77 as GNU standard skip test indicator
%
% Inputs
% ------
% * filename: directory or filename to look for
% * path_path: 'dir' or 'file'
narginchk(2,2)
validateattributes(path_type, {'char'}, {'vector'}, mfilename, 'dir or file', 2)

if strcmp(path_type, 'file')
    if ~is_file(filename)
      if isinteractive
        error([filename, ' is not a file.'])
      else
        fprintf(2, [filename, ' is not a file.\n'])
        exit(77)
      end
    end
elseif strcmp(path_type, 'dir')
    if ~is_folder(filename)
      if isinteractive
        error([filename, ' is not a directory.'])
      else
        fprintf(2, [filename, ' is not a directory.\n'])
        exit(77)
      end
    end

end % if

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
