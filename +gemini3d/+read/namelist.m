%% NAMELIST read Fortran namelist to struct

function params = namelist(filename, namelist)
arguments
  filename (1,1) string {mustBeFile}
  namelist (1,1) string
end

params = struct();

fid = fopen(filename);

%% find the specified namelist in the file
while ~feof(fid)
  line = fgetl(fid);
  % allow zero or more spaces before the namelist that starts with "&"
  nml = regexp(line, "^\s*&(" + namelist + ")\s*$", 'match');
  if ~isempty(nml)
     break
  end
end

if isempty(nml)
  fclose(fid); % this is necessary to avoid dangling handles on catch
  error('gemini3d:read:namelist:namelist_not_found', 'did not find namelist %s in %s', namelist, filename)
end

%% read all variables of the namelist
while ~feof(fid)
  line = fgetl(fid);
  % detect end of namelist "/" by itself on a line
  mend = regexp(line, '^\s*/\s*$', 'match');
  if ~isempty(mend)
     break
  end

  % detect unexpected new namelist and error
  b = regexp(line, "^\s*&", 'match');
  if ~isempty(b)
    error("Namelist %s was unterminated and %s leaked in", namelist, line)
  end

% match key-value pairs with "=" in-between.
% if value is a string, it may be enclosed in single or double quotes
  pat = '^\s*(\w+)\s*=\s*[''\"]?([^!''\"]+)[''\"]?';
  matches = regexp(line, pat, 'tokens');
  if isempty(matches)
    % blank, commented or malformed line
    continue
  end

  % need textscan instead of sscanf to handle corner cases
  vals = cell2mat(textscan(matches{1}{2}, '%f', Delimiter=','));
  if isempty(vals)  % must be a string
    v = strip(extractAfter(string(line), "="));
    if contains(v, "!")
      v = strip(extractBefore(v, "!"));
    end
    v = strip(split(v, ","));
    vals = strip(strip(v, char(39)), char(34));
  else
    vals = vals(:).';
  end

  params.(matches{1}{1}) = vals;
end
fclose(fid);

if isempty(mend)
  error('gemini3d:read:namelist:namelist_syntax', 'did not read end of namelist %s in %s', namelist, filename)
end

end
