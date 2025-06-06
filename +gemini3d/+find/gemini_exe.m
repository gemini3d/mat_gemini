function exe = gemini_exe(name)
%% Find an executable from the Gemini3D program set, using paths common to Gemini3D
arguments
  name (1,1) string {mustBeNonzeroLengthText}
end

gemini3d.sys.check_stdlib()

paths = [fullfile(gemini3d.root(), ".."), ...
  string(getenv("GEMINI_ROOT")), ...
  string(getenv("CMAKE_PREFIX_PATH"))];
bindirs = [".", "msis", "bin", "build", "build/bin", "build/msis", ...
  "build/Release", "build/RelWithDebInfo", "build/Debug"];

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
