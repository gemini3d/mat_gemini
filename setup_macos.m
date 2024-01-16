function setup_macos()

%% MacOS PATH workaround
% Matlab does not seem to load .zshrc or otherwise pickup shell "export" like
% Matlab on Linux, hence this MacOS-specific workaround

if ~ismac
  return
end

prefix_path = ["/opt/homebrew/bin", "/usr/local/bin", "/opt/local/bin"];

sys_path = getenv("PATH");

[ret, homebrew_prefix] = system('brew --prefix');
if ret == 0
  prefix_path = [homebrew_prefix, prefix_path];
end

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

end % function
