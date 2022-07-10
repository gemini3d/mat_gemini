function setup()
%% run this before running Gemini Matlab scripts

assert(~verLessThan('matlab', '9.9'), 'Matlab >= R2020b is required')

cwd = fileparts(mfilename('fullpath'));
addpath(cwd)
setenv("MATGEMINI", cwd)
%% ensure matlab-stdlib is present
stdlib_dir = fullfile(cwd, "matlab-stdlib");
if ~isfolder(fullfile(stdlib_dir, "+stdlib"))
  assert(system("git submodule update --init") == 0, "Run this command from Terminal, then run mat_gemini/setup.m script again: \n%s", "git submodule update --init")
end

addpath(stdlib_dir)

%% check if msis_setup is found--needed to setup simulations
exe = gemini3d.find.gemini_exe("msis_setup");
if isempty(exe)
  warning("If Gemini3D already installed, set environment variable GEMINI_ROOT to the top level Gemini3D install" + ...
  " directory e.g. ~/libgem if ~/libgem/bin/msis_setup exists.")
end

end % function
