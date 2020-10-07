function setup()
%% run this before running Gemini Matlab scripts

gemini3d_git = "https://github.com/gemini3d/gemini3d.git";
gemini3d_dirname = "gemini3d";
cwd = fileparts(mfilename('fullpath'));
addpath(cwd)

fix_macos()

gemini_root = getenv("GEMINI_ROOT");
if isempty(gemini_root)
  gemini_root = gemini3d.fileio.absolute_path(fullfile(cwd, "..", gemini3d_dirname));

  ret = 0;
  if ~isfolder(gemini_root)
    cmd = "git -C " + fullfile(gemini_root, "..") + " clone " + gemini3d_git + " " + gemini3d_dirname;
    ret = system(cmd);
  end

  if ret == 0 && isfolder(gemini_root)
    setenv('GEMINI_ROOT', gemini_root)
  else
    warning("Trouble setting up / finding Gemini3D. Not able to run simulations. Please set environment variable GEMINI_ROOT to Gemini3D directory.")
  end
end


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
