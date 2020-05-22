function params = read_namelist(filename, namelist)

narginchk(2,2)
assert(is_file(filename), [filename, ' not found.'])
validateattributes(namelist, {'char'}, {'vector'}, mfilename, 'namelist name', 2)

params = struct();

fid=fopen(filename);
while ~feof(fid)
  line = fgetl(fid);
  mgrp = regexp(line, ['^\s*&(', namelist, ')'], 'match');
  if ~isempty(mgrp)
     break
  end
end

if isempty(mgrp)
  error('read_namelist:namelist_not_found', 'did not find namelist %s in %s', namelist, filename)
end

while ~feof(fid)
  line = fgetl(fid);
  % detect end of namelist
  mend = regexp(line, '^\s*/\s*$', 'match');
  if ~isempty(mend)
     break
  end

  pat = '^\s*(\w+)\s*=\s*[''\"]?([^!''\"]*)[''\"]?';
  matches = regexp(line, pat, 'tokens');
  if isempty(matches)  % blank, commented or malformed line
    continue
  end

  % need textscan instead of sscanf to handle corner cases
  vals = cell2mat(textscan(matches{1}{2}, '%f','Delimiter',','));
  if isempty(vals)  % must be a string
    vals = matches{1}{2};
  else
    vals = vals(:).';
  end

  params.(matches{1}{1}) = vals;
end
fclose(fid);

if isempty(mend)
  error('read_namelist:namelist_syntax', 'did not read end of namelist %s in %s', namelist, filename)
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
