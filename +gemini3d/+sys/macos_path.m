function macos_path()

%% MacOS PATH workaround
% Matlab does not load .zshrc if started from the Applications dock Matlab icon

if ~ismac()
  return
end

%% homebrew path
prefixes = getenv("HOMEBREW_PREFIX");
if isfolder(prefixes)
  addpath_if_needed(fullfile(prefixes, 'bin'))
else
  prefixes = fullfile(["/opt/homebrew", "/usr/local"], "bin");
  i = find(isfolder(prefixes), 1);
  if ~isempty(i)
    addpath_if_needed(prefixes(i))
  end
end

%% matlab own path
matlab_path = fullfile(matlabroot, "bin");

addpath_if_needed(matlab_path)

end % function


function addpath_if_needed(prefix_path)
arguments
  prefix_path (1,1) string {mustBeFolder}
end

sys_path = getenv('PATH');

paths = split(sys_path, pathsep);

if ~any(contains(paths, prefix_path))
  disp("Adding prefix to Matlab path: " + prefix_path)
  sys_path = append(prefix_path, pathsep, sys_path);
  setenv('PATH', sys_path)
end

end
