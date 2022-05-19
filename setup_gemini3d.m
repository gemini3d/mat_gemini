function setup_gemini3d(install_prefix)
%% setup Gemini3D (build with CMake)
% this is run automatically by functions that need it like gemini3d.run and gemini3d.model.setup
% however if you wish you can run it manually to setup gemini3d
arguments
  install_prefix string {mustBeScalarOrEmpty} = string.empty
end

import gemini3d.sys.cmake

%% ensure all paths are OK
cwd = fullfile(fileparts(mfilename('fullpath')));
run(fullfile(cwd, 'setup.m'))

cmake(cwd, fullfile(cwd, "build"), install_prefix);

if isempty(install_prefix)
  setenv("GEMINI_ROOT", cwd)
else
  setenv("GEMINI_ROOT", install_prefix)
end

disp("Gemini3D installed to: " + getenv("GEMINI_ROOT"))

end
