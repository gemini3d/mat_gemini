function setup_homebrew()

%% MacOS Homebrew PATH workaround
% Matlab does not seem to load .zshrc or otherwise pickup shell "export" like
% Matlab on Linux or Windows does, so we apply these MacOS-specific workaround

import stdlib.fileio.which

sys_path = getenv("PATH");
homebrew_path = string(getenv("HOMEBREW_PREFIX"));

if strlength(homebrew_path) == 0
  homebrew_path = fileparts(which("brew"));
end
if strlength(homebrew_path) == 0
  homebrew_path = ["/opt/homebrew/bin", "/usr/local/bin"];
end

for p = homebrew_path
  if contains(sys_path, p)
    return
  elseif isfolder(p)
    disp("Adding Homebrew to Matlab path: " + p)
    sys_path = p + pathsep + sys_path;
    break
  end
end

setenv('PATH', sys_path)

end % function
