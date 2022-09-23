function check_stdlib()

cwd = fileparts(mfilename('fullpath'));
r = fullfile(cwd, "../..");

s = what(fullfile(r, 'matlab-stdlib'));

if isempty(s) || ~any(contains(s.packages, 'stdlib'))
  error("Run this command from in Terminal, then run mat_gemini/setup.m script again:\n%s\n%s\n%s", ...
        "git -C " + r + " submodule update --init", ...
        "if mat_gemini/setup.m still doesn't work, perhaps try recloning mat_gemini like:", ...
        "git clone --recurse-submodules https://github.com/gemini3d/mat_gemini")
end

if ~contains(path, r)
  addpath(s.path)
end

end
