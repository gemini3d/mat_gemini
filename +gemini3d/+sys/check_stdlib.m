function is_ok = check_stdlib()

persistent stdlib_ok

if ~isempty(stdlib_ok) && stdlib_ok
  if nargout > 0, is_ok = stdlib_ok; end
  return
end

cwd = fileparts(mfilename('fullpath'));
r = fullfile(cwd, "../..");

p = what(fullfile(r, 'matlab-stdlib'));
if ~isempty(p)
  p = p(1);  % first entry is from matlabpath, later comes directory of that name
end

if isempty(p) || ~any(contains(p.packages, 'stdlib'))
  error("gemini3d:sys:check_stdlib:environment_error", ...
    "Run this command from in Terminal, then run mat_gemini/setup.m script again:\n%s\n%s\n%s", ...
    "git -C " + r + " submodule update --init", ...
    "if mat_gemini/setup.m still doesn't work, perhaps try recloning mat_gemini like:", ...
    "git clone --recurse-submodules https://github.com/gemini3d/mat_gemini")
end

if ~contains(path(), r)
  addpath(p.path)
end

assert(stdlib.expanduser("~") ~= "~", "stdlib.expanduser() did not expand tilde ~")

stdlib_ok = true;
if nargout > 0, is_ok = stdlib_ok; end

end
