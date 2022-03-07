function setup_gemini3d(prefix)
%% setup Gemini3D (build with CMake)
% this is run automatically by functions that need it like gemini3d.run and gemini3d.model.setup
% however if you wish you can run it manually to setup gemini3d
arguments
  prefix string {mustBeScalarOrEmpty} = string.empty
end

import gemini3d.sys.cmake

%% ensure all paths are OK
cwd = fullfile(fileparts(mfilename('fullpath')));
run(fullfile(cwd, 'setup.m'))

cmake_args = string.empty;
if ~isempty(prefix)
  cmake_args = "-DCMAKE_PREFIX_PATH:PATH=" + prefix;
end

cmake(cwd, fullfile(cwd, "build"), cmake_args);

setenv("GEMINI_ROOT", cwd)

end
