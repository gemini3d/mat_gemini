function p = expand_envvar(p)
% expands environment variable found between first pair of @ signs.
% errors if environment variable doesn't exist.
% returns input if no @ found.

arguments
  p {mustBeTextScalar}
end

i = strfind(p, '@');
if length(i) < 2
  return
end

if ischar(p)
  envvar = p(i(1)+1:i(2)-1);
else
  envvar = extractBetween(p, i(1)+1, i(2)-1);
end
r = getenv(envvar);
if strlength(r) < 1
  error("gemini3d:fileio:expand_envvar", "environment variable %s not defined or empty", envvar)
end

p = fullfile(extractBefore(p, i(1)), r, extractAfter(p, i(2)));

end 
