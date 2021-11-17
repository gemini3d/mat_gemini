function exe = get_gemini_exe(name)
arguments
  name (1,1) string {mustBeNonzeroLengthText}
end

import stdlib.fileio.which

paths = [string(getenv("MATGEMINI")), string(getenv("GEMINI_ROOT"))];
bindirs = ["build", ".", "bin", "build/bin", "build/Release", "build/RelWithDebInfo", "build/Debug"];

for p = paths
  for b = bindirs
    exe = which(name, fullfile(p, b));
    if ~isempty(exe)
      return
    end
  end
end
end % function
