%% setup Gemini3D (build with CMake)
% this is run automatically by functions that need it like gemini3d.run and gemini3d.model.setup
% however if you wish you can run it manually to setup gemini3d

%% ensure all paths are OK
run(fullfile(fileparts(mfilename('fullpath')), 'setup.m'))

src_dir = getenv("MATGEMINI");
gemini3d.sys.cmake(src_dir, fullfile(src_dir, "build"));
exe = gemini3d.sys.get_gemini_exe("msis_setup");

setenv("GEMINI_ROOT", src_dir)
