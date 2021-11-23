%% setup Gemini3D (build with CMake)
% this is run automatically by functions that need it like gemini3d.run and gemini3d.model.setup
% however if you wish you can run it manually to setup gemini3d

%% ensure all paths are OK
cwd = fullfile(fileparts(mfilename('fullpath')));
run(fullfile(cwd, 'setup.m'))

gemini3d.sys.cmake(cwd, fullfile(cwd, "build"));

setenv("GEMINI_ROOT", cwd)
