function p = expand_simroot(p)

key = "@GEMINI_SIMROOT@";

if startsWith(p, key)
  r = getenv(extractBetween(key, 2, strlength(key)-1));
  assert(~isempty(r), p + " refers to undefined environment variable GEMINI_SIMROOT. Set it to location to store/load Gemini3D simulations.")

  p = fullfile(r, extractAfter(p, key));
end

end
