function build_gemini3d(gemini_root, exe)
arguments
  gemini_root (1,1) string = getenv("GEMINI_ROOT")
  exe (1,1) string = gemini3d.sys.gemini_exe_name(fullfile(gemini_root, "build/gemini.bin"))
end
% don't use ctest -S ... because it will infinitely loop CMake

if isempty(gemini_root)
  error("build_gemini3d:environment_error", "please run mat_gemini/setup.m to setup your environment")
end

exe = gemini3d.posix(exe);
gemini_root = gemini3d.posix(gemini_root);

build_dir = fileparts(exe);

if ~gemini3d.sys.cmake_atleast("3.15")
  error("build_gemini3d:environment_error", "CMake >= 3.15 required for Gemini")
end

if ~isfolder(gemini_root)
  error("build_gemini3d:file_not_found", "gemini_root source directory not found: " + gemini_root)
end

cfg_cmd = "cmake -B" + build_dir + " -S" + gemini_root;
ret = system(cfg_cmd);
if ret ~= 0
  error("build_gemini3d:runtime_error", "Could not configure Gemini3D in " + gemini_root)
end

build_cmd = "cmake --build " + build_dir;
ret = system(build_cmd);
if ret ~= 0
  error("build_gemini3d:runtime_error", "Could not build Gemini3D in " + gemini_root)
end

end
