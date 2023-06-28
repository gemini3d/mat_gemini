function setup()
%% run this before running Gemini Matlab scripts

assert(~isMATLABReleaseOlderThan('R2020b'), 'MatGemini requires Matlab >= R2020b. You are running Matlab %s', version())

cwd = fileparts(mfilename('fullpath'));
addpath(cwd)

%% ensure matlab-stdlib is present
gemini3d.sys.check_stdlib()

%% check if msis_setup is found--needed to setup simulations
exe = gemini3d.find.gemini_exe("msis_setup");
if isempty(exe)
  warning("If Gemini3D already installed, set environment variable GEMINI_ROOT to the top level Gemini3D install" + ...
  " directory e.g. ~/libgem if ~/libgem/bin/msis_setup exists.")
end

end % function
