function r = root()
%% return top-level MatGemini path

p = what('gemini3d');
if isempty(p)
  rp = fullfile(fileparts(mfilename('fullpath')), "..");
  error("gemini3d:root:FileNotFound", ...
    "Gemini3D MatGemini package not found. Try running 'setup()' from the mat_gemini/ directory, which should be at: %s", rp)
end

gp = p.path;
if isempty(gp)
  error("gemini3d:root:FileNotFound", ...
    "Gemini3D MatGemini package was found, but has an unknown path. This is an unexpected error.")
end

root = string(gp);

r = root(1);

end
