function setvars = oneapi_setvars()
% on Windows currently Gemini3D must be built either in Windows Subsystem
% for Linux, or using Intel oneAPI. Since oneAPI uses DLLs, the Matlab
% environment must also be setup for oneAPI or gemini3d.run will fail with
% missing DLL error.
%
% this must be called with '&&' in the same system() command as the
% executable desired to run. Matlab uses a new shell for each system()
% call.
%
% need double-quotes due to spaces in path
%
% example:
%
% setvars = oneapi_setvars()
% cmd = ['"', char(setvars), '" && icx --version'];
% [ret, msg] = system(cmd);

assert(isenv("ONEAPI_ROOT"), "environnment variable ONEAPI_ROOT is necessary to locate oneAPI.")

oneapi_root = getenv("ONEAPI_ROOT");

setvars = fullfile(oneapi_root, "setvars.bat");

assert(isfile(setvars), "setvar.bat not found under " + oneapi_root)

end
