function p = expand_simroot(p, key)
arguments
  p (1,1) string
  key (1,1) string = "@GEMINI_SIMROOT@"
end

if startsWith(p, key)
  r = getenv(extractBetween(key, 2, strlength(key)-1));
  if isempty(r)
    r = stdlib.fileio.expanduser("~/gemini_sims");
    disp(p + " refers to undefined environment variable GEMINI_SIMROOT. Fallback to " + r)
  end
  p = fullfile(r, extractAfter(p, key));
end

end
