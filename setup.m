function setup()
%% run this before running Gemini Matlab scripts

assert(~verLessThan('matlab', '9.9'), 'Matlab >= R2020b is required')

cwd = fileparts(mfilename('fullpath'));
addpath(cwd)
setenv('MATGEMINI', cwd)

%% ensure matlab-stdlib is present
stdlib_dir = fullfile(cwd, "matlab-stdlib");
assert(system("git submodule update --init") == 0, ...
  "could not update Matlab-stdlib submodule. Please make a GitHub Issue for this.")
addpath(stdlib_dir)
%% add our local binary dir to PATH (e.g. for Zstd)
matGemini_bin = fullfile(cwd, "build", "bin");
if ~contains(getenv("PATH"), matGemini_bin)
  setenv('PATH', matGemini_bin + pathsep + getenv("PATH"))
end
%% fix MacOS PATH since ZSH isn't populated into Matlab
if ismac
  homebrew_path()
end

end % function


function homebrew_path()

%% MacOS Homebrew PATH workaround
% Matlab does not seem to load .zshrc or otherwise pickup shell "export" like
% Matlab on Linux or Windows does, so we apply these MacOS-specific workaround

sys_path = getenv("PATH");
if contains(sys_path, getenv("HOMEBREW_PREFIX"))
  return
end

for p = ["/opt/homebrew/bin", "/usr/local/bin"]
  if isfolder(p) && ~contains(sys_path, p)
    sys_path = p + pathsep + sys_path;
  end
end

setenv('PATH', sys_path)

end % function
