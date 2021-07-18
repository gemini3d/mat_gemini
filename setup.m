function setup()
%% run this before running Gemini Matlab scripts

assert(~verLessThan('matlab', '9.9'), 'Matlab >= R2020b is required')

cwd = fileparts(mfilename('fullpath'));
meta = jsondecode(fileread(fullfile(cwd, "libraries.json")));

gemini3d_dirname = "gemini3d";

addpath(cwd)
setenv('MATGEMINI', cwd)

%% ensure matlab-stdlib is present
stdlib_dir = fullfile(cwd, "matlab-stdlib");
if ~isfolder(fullfile(stdlib_dir, "+stdlib"))
  cmd = "git submodule update --init";
  assert(system(cmd) == 0, "could not update Matlab-stdlib submodule. Please make a GitHub Issue for this.")
end

addpath(stdlib_dir)
%% fix MacOS PATH since ZSH isn't populated into Matlab
fix_macos()
%% Get Gemini3D if not present
gemini_root = stdlib.fileio.expanduser(getenv("GEMINI_ROOT"));
if isempty(gemini_root) || strlength(gemini_root) == 0
  gemini_root = stdlib.fileio.absolute_path(fullfile(cwd, "..", gemini3d_dirname));
end

canary = fullfile(gemini_root, "CMakeLists.txt");

if ~isfile(canary)
  ret = -1;
  % assumption behind pause is git clone will complete << 5 seconds
  cmd = join(["git -C", fullfile(cwd, ".."), "clone", meta.gemini3d.url, gemini3d_dirname]);
  pause(5*rand)
  if ~isfile(canary)
    % may have race condition if tests run in parallel
    disp(cmd)
    ret = system(cmd);
  end

  if ret == 0
    cmd = join(["git -C", gemini_root, "checkout", meta.gemini3d.tag]);
    disp(cmd)
    ret = system(cmd);
    assert(ret == 0, "problem Git checkout Gemini3D")
  else
    pause(5)
    % waiting to see if race condition with other workers Git clones
  end
end

assert(isfile(canary), "Trouble setting up / finding Gemini3D. Not able to run simulations. Please set environment variable GEMINI_ROOT to Gemini3D directory.")

setenv('GEMINI_ROOT', gemini_root)

end % function


function fix_macos()

%% MacOS PATH workaround
% Matlab does not seem to load .zshrc or otherwise pickup shell "export" like
% Matlab on Linux or Windows does, so we apply these MacOS-specific workaround
if ~ismac
  return
end

sys_path = getenv("PATH");
needed_paths = ["/usr/local/bin", "/opt/homebrew/bin"];
for np = needed_paths
  if isfolder(np) && ~contains(sys_path, np)
    sys_path = np + pathsep + sys_path;
  end
end

setenv('PATH', sys_path)

end % function
