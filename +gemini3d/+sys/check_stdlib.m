function is_ok = check_stdlib(url)
arguments
  url {mustBeTextScalar} = ''
end

persistent stdlib_ok

if ~isempty(stdlib_ok) && stdlib_ok
  if nargout > 0, is_ok = stdlib_ok; end
  return
end

p = which('stdlib.expanduser');

if isempty(p)
  if ~isempty(url)
    pkg = websave('stdlib.mltbx', url);
    matlab.addons.toolbox.installToolbox(pkg);
  end
end

stdlib_ok = stdlib.expanduser("~") ~= "~";

if nargout > 0, is_ok = stdlib_ok; end

end
