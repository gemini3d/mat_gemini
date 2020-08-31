function exist_or_skip(filename, path_type)
% if paths not exist, exit code 77 as GNU standard skip test indicator
%
% Inputs
% ------
% * filename: directory or filename to look for
% * path_path: 'dir' or 'file'
arguments
  filename (1,1) string
  path_type (1,1) string {mustBeMember(path_type, ["dir", "file"])}
end

switch path_type
case "file"
  if ~isfile(filename)
    if gemini3d.sys.isinteractive
      error('exist_or_skip:file_not_found', 'could not find %s', filename)
    else
      fprintf(2, [filename, ' is not a file.\n'])
      exit(77)
    end
  end
case "dir"
  if ~isfolder(filename)
    if gemini3d.sys.isinteractive
      error('exist_or_skip:not_a_directory', 'could not find %s', filename)
    else
      fprintf(2, [filename, ' is not a directory.\n'])
      exit(77)
    end
  end
otherwise, error("must be dir or file")
end % switch

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
