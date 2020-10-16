function build_gemini3d(gemini_root, exe)
arguments
  gemini_root (1,1) string = getenv("GEMINI_ROOT")
  exe (1,1) string = gemini3d.sys.gemini_exe_name(fullfile(gemini_root, "build/gemini.bin"))
end
% don't use ctest -S ... because it will infinitely loop CMake

if isempty(gemini_root)
  error("build_gemini3d:environment_error", "please run mat_gemini/setup.m to setup your environment")
end

build_dir = fileparts(exe);

gemini3d.sys.cmake(gemini_root, build_dir)

end
