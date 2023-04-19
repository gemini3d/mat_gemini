function is_ok = check_scripts()
% check that mat_gemini-scripts available

persistent gemscr_ok

if ~isempty(gemscr_ok) && gemscr_ok
  if nargout > 0, is_ok = gemscr_ok; end
  return
end

cwd = fileparts(mfilename('fullpath'));
r = fullfile(cwd, "../../..");

p = what(fullfile(r, 'mat_gemini-scripts'));
if ~isempty(p)
  p = p(1);  % first entry is from matlabpath, later comes directory of that name
end

if isempty(p) || ~any(contains(p.packages, 'gemscr'))
  error("gemini3d:sys:check_scripts:environment_error", ...
    "Could not find mat_gemini-scripts. Try this command from Terminal:\n%s\n%s\n%s", ...
    "git -C " + r + " clone https://github.com/gemini3d/mat_gemini-scripts")
end

if ~contains(path(), r)
  addpath(p.path)
end

gemscr_ok = true;
if nargout > 0, is_ok = gemscr_ok; end

end
