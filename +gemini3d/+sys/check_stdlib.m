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
  ret = system("git -C " + r + " submodule update --init");
  assert(ret == 0, "could not Git submodule update matlab-stdlib in " + r)
end

if ~contains(path(), r)
  addpath(p.path)
end

assert(stdlib.expanduser("~") ~= "~", "stdlib.expanduser() did not expand tilde ~")

stdlib_ok = true;
if nargout > 0, is_ok = stdlib_ok; end

end
