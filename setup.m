function setup(envfile)
arguments
  envfile {mustBeTextScalar} = ''
end
%% run this before running Gemini Matlab scripts

assert(~isMATLABReleaseOlderThan('R2021a'), 'MatGemini requires Matlab >= R2021a. You are running Matlab %s', version())

cwd = fileparts(mfilename('fullpath'));
addpath(cwd)
setenv("MATGEMINI", cwd)

%% ensure matlab-stdlib is present
gemini3d.sys.check_stdlib()

%% load environment file if it exists
if ~isMATLABReleaseOlderThan('R2023a')
  e = stdlib.expanduser(envfile);
  if isfile(e)
    disp("Loading environment file: " + e)
    loadenv(e)
  end
end

%% check if msis_setup is found--needed to setup simulations
exe = gemini3d.find.gemini_exe("msis_setup");
if isempty(exe)
  warning("gemini3d:setup:FileNotFound", "If Gemini3D already installed, set environment variable GEMINI_ROOT to the top level Gemini3D install directory.")
end

disp("Using Gemini3D-MSIS " + exe)

end % function
