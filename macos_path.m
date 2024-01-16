function macos_path()

%% MacOS PATH workaround
% Matlab does not load .zshrc

if ~ismac
  return
end

%% homebrew path
prefix_path = ["/opt/homebrew/bin", "/usr/local/bin", "/opt/local/bin"];

[ret, homebrew_prefix] = system('brew --prefix');
if ret == 0
  prefix_path = [strip(homebrew_prefix), prefix_path];
end

addpath_if_needed(prefix_path)

%% matlab own path
matlab_path = fullfile(matlabroot, "bin");

addpath_if_needed(matlab_path)

end % function


function addpath_if_needed(prefix_path)

sys_path = getenv("PATH");

for p = prefix_path
  if contains(sys_path, p)
    return
  elseif isfolder(p)
    disp("Adding prefix to Matlab path: " + p)
    sys_path = p + pathsep + sys_path;
    break
  end
end

setenv('PATH', sys_path)

end
