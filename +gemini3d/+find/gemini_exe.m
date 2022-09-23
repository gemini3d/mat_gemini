function exe = gemini_exe(name)
arguments
  name (1,1) string {mustBeNonzeroLengthText}
end
%% Find an executable from the Gemini3D program set, using paths common to Gemini3D

import stdlib.fileio.which
import stdlib.fileio.absolute_path


paths = [fullfile(gemini3d.root(), ".."), ...
  string(getenv("GEMINI_ROOT")), ...
  string(getenv("CMAKE_PREFIX_PATH")), ...
  "~/libgem", "~/libgem_gnu", "~/libgem_intel"];
bindirs = [".", "bin", "build", "build/bin", ...
  "build/Release", "build/RelWithDebInfo", "build/Debug"];

for p = paths
  if isempty(p), continue, end
  for b = bindirs
    exe = which(name, fullfile(p, b));
    if ~isempty(exe)
      return
    end
  end
end
end % function
