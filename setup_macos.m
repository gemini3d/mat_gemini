function setup_macos()

%% MacOS PATH workaround
% Matlab does not seem to load .zshrc or otherwise pickup shell "export" like
% Matlab on Linux or Windows does, so we apply these MacOS-specific workaround

import stdlib.fileio.which

sys_path = getenv("PATH");

prefix_path = [getenv("HOMEBREW_PREFIX"), ...
fileparts(which("brew")), fileparts(which("port")), ...
"/opt/homebrew/bin", "/usr/local/bin", "/opt/local/bin"];

for p = prefix_path
  if strlength(p) == 0
    continue
  elseif contains(sys_path, p)
    return
  elseif isfolder(p)
    disp("Adding prefix to Matlab path: " + p)
    sys_path = p + pathsep + sys_path;
    break
  end
end

setenv('PATH', sys_path)

end % function
