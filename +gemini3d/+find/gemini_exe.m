function exe = gemini_exe(name)
%% Find an executable from the Gemini3D program set, using paths common to Gemini3D
arguments
  name (1,1) string {mustBeNonzeroLengthText}
end


gemini3d.sys.check_stdlib()

if ispc() && ~endsWith(name, ".exe")
  name = name + ".exe";
end

paths = [fullfile(gemini3d.root(), ".."), ...
  string(getenv("GEMINI_ROOT")), ...
  string(getenv("CMAKE_PREFIX_PATH")), ...
  fullfile(gemini3d.root(), "../../gemini3d/build/local")];

bindirs = [".", "bin"];

for p = paths
  if isempty(p), continue, end
  for b = bindirs
    % important to expanduser(p) because which() may find the ~/exe on Unix-like
    % systems, but stdlib.subprocess_run doesn't like the leading tilde.
    exe = stdlib.which(name, stdlib.join(stdlib.expanduser(p), b));
    if ~isempty(exe)
      return
    end
  end
end
end % function
