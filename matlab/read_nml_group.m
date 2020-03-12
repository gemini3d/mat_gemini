function params = read_nml_group(filename, group)

narginchk(2,2)
assert(is_file(filename), [filename, ' not found.'])
validateattributes(group, {'char'}, {'vector'}, mfilename, 'nml group name', 2)

params = struct();

fid=fopen(filename);
while ~feof(fid)
  line = fgetl(fid);
  mgrp = regexp(line, ['^\s*&', group], 'match');
  if ~isempty(mgrp)
     break
  end
end

assert(~isempty(mgrp), ['did not find group ', group, ' in ', filename])

while ~feof(fid)
  line = fgetl(fid);
  % detect end of group
  mend = regexp(line, '^\s*/\s*$', 'match');
  if ~isempty(mend)
     break
  end

  comment_line = regexp(line, '^\s*!', 'match');
  if ~isempty(comment_line)
    continue
  end

  [k, v] = strtok(line, '=');
  if isempty(k) || isempty(v)  % blank or malformed line
    continue
  end
  v = strtok(v(2:end), '!');  % discard comments
  % need textscan instead of sscanf to handle corner cases
  vals = cell2mat(textscan(v, '%f','Delimiter',','));
  if isempty(vals)  % must be a string
    vals = strtrim(strrep(v, char(39), ''));
  else
    vals = vals(:).';
  end

  params.(strtrim(k)) = vals;
end
fclose(fid);

assert(~isempty(mend), ['did not read end of group ', group, ' in ', filename])

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