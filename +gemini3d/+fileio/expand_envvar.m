function p = expand_envvar(p)
% expands environment variable found between first pair of @ signs.
% errors if environment variable doesn't exist.
% returns input if no @ found.

arguments
  p (1,1) string
end

i = strfind(p, "@");
if length(i) < 2
  return
end

envvar = extractBetween(p, i(1)+1, i(2)-1);
r = getenv(envvar);
if strlength(r) < 1
  error("environment variable %s not defined or empty", envvar)
end

p = fullfile(extractBefore(p, i(1)), r, extractAfter(p, i(2)));

end % function expand_envvar
