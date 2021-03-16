function p = expand_simroot(p)

key = "@GEMINI_SIMROOT@";

if startsWith(p, key)
  r = getenv(extractBetween(key, 2, strlength(key)-1));
  if isempty(r)
    error("gemini3d:fileio:read_nml", p + " refers to undefined environment variable GEMINI_SIMROOT. Set it to location to store/load Gemini3D simulations.")
  end

  p = fullfile(r, extractAfter(p, key));
end

end
