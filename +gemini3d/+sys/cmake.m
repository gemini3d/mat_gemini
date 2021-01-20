function cmake(src_dir, build_dir, target)
% build program using CMake and default generator
% to specify generator with CMake >= 3.15 set environment variable CMAKE_GENERATOR
arguments
  src_dir (1,1) string
  build_dir (1,1) string
  target string = string.empty
end

% must be absolute path for Unix-like, where cannot traverse upwards from non-existent dir
% build_dir needs it as well or CMake will use pwd instead
src_dir = gemini3d.posix(gemini3d.fileio.absolute_path(src_dir));
build_dir = gemini3d.posix(gemini3d.fileio.absolute_path(build_dir));

assert(isfolder(src_dir), "source directory not found: %s", src_dir)
assert(isfile(fullfile(src_dir, "CMakeLists.txt")), "%s does not contain CMakeLists.txt", src_dir)

assert(system("cmake --version") == 0, 'CMake not found')

%% configure
% don't use ctest -S as it will infinite loop with MSIS build/test
cmd = "cmake -S" + src_dir + " -B" + build_dir + " -DBUILD_TESTING:BOOL=off";
if system(cmd) ~=0
  % try reconfiguring
  if isfile(fullfile(build_dir, "CMakeCache.txt"))
    rmdir(build_dir, 's')
  end
  assert(system(cmd) == 0, "error configuring %s with CMake", src_dir)
end

%% build
cmd = "cmake --build " + build_dir + " --parallel";
if ~isempty(target)
  cmd = cmd + " --target " + target;
end
ret = system(cmd);
assert(ret == 0, 'error building with CMake in %s', build_dir)

end % function
