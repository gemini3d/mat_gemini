function macos_path()

%% MacOS PATH workaround
% Matlab does not load .zshrc

if ~ismac
  return
end

%% homebrew path
for brew = ["brew", "/opt/homebrew/bin/brew", "/usr/local/bin/brew"]
  [ret, homebrew_prefix] = system(brew + " --prefix");
  if ret == 0
    addpath_if_needed(fullfile(strip(homebrew_prefix), "bin"))
    break
  end
end


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
