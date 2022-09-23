function r = root()
%% return top-level MatGemini path

p = what('gemini3d'); % Matlab package on Matlab path, and directories in cwd
if isempty(p) || ~any(contains(p.classes, 'Gemini3d'))
  rp = fullfile(fileparts(mfilename('fullpath')), "..");
  error("gemini3d:root:FileNotFound", ...
    "Gemini3D MatGemini package not found. Try running 'setup()' from the mat_gemini/ directory, which should be at: %s", rp)
end

gp = p(1).path;
assert(~isempty(gp), "Gemini3D MatGemini package was found, but has an unknown path. This is an unexpected error.")

r = string(gp);

end
