function exe = get_gemini_exe(name)
arguments
  name (1,1) string {mustBeNonzeroLengthText}
end

import stdlib.fileio.which
import stdlib.fileio.absolute_path

paths = [fullfile(what('gemini3d').path, ".."), string(getenv("GEMINI_ROOT"))];
bindirs = ["build", ".", "bin", "build/bin", "build/Release", "build/RelWithDebInfo", "build/Debug"];

for p = paths
  for b = bindirs
    exe = which(name, fullfile(p, b));
    if ~isempty(exe)
      exe = absolute_path(exe);
      return
    end
  end
end
end % function
