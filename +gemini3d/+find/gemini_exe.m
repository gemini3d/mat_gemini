function exe = gemini_exe(name)
arguments
  name (1,1) string {mustBeNonzeroLengthText}
end
%% Find an executable from the Gemini3D program set, using paths common to Gemini3D

import stdlib.fileio.which
import stdlib.fileio.absolute_path


paths = [fullfile(gemini3d.root(), ".."), ...
  string(getenv("GEMINI_ROOT")), ...
  string(getenv("CMAKE_PREFIX_PATH"))];
bindirs = [".", "bin", "build", "build/bin", ...
  "build/Release", "build/RelWithDebInfo", "build/Debug"];

exe = string.empty;
for p = paths
  for b = bindirs
    if ispc
      % stdlib.fileio.which isn't used on Windows due to possible issue
      % with WSL executable from Windows-native Matlab
      e = fullfile(p, b, name);
      if isfile(e)
        exe = e;
        return
      end
    else
      exe = which(name, fullfile(p, b));
      if ~isempty(exe)
        exe = absolute_path(exe);
       return
      end
    end
  end
end
end % function
