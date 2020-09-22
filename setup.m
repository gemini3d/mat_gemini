function setup()
%% run this before running Gemini Matlab scripts

cwd = fileparts(mfilename('fullpath'));
addpath(cwd)

gemini_root = getenv("GEMINI_ROOT");
if isempty(gemini_root)
  gemini_root = gemini3d.fileio.absolute_path(fullfile(cwd, '../gemini3d/'));
  if isfolder(gemini_root)
    setenv('GEMINI_ROOT', gemini_root)
  end
end

fix_macos()
end % function


function fix_macos()

%% MacOS PATH workaround
% Matlab does not seem to load .zshrc or otherwise pickup shell "export" like
% Matlab on Linux or Windows does, so we apply these MacOS-specific workaround
if ~ismac
  return
end

sys_path = getenv("PATH");
needed_paths = "/usr/local/bin";
for np = needed_paths
  if isfolder(np) && ~contains(sys_path, np)
    sys_path = np + pathsep + sys_path;
  end
end

setenv('PATH', sys_path)

end % function
