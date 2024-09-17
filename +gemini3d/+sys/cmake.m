function cmake(src_dir, build_dir, install_dir, cmake_args)
% build program using CMake and default generator
% specify CMake generator: set environment variable CMAKE_GENERATOR
arguments
  src_dir (1,1) string
  build_dir (1,1) string
  install_dir string {mustBeScalarOrEmpty} = string.empty
  cmake_args string {mustBeScalarOrEmpty} = string.empty
end

% must be absolute path for Unix-like, where cannot traverse upwards from non-existent dir
% build_dir needs it as well or CMake will use pwd instead
src_dir = stdlib.posix(stdlib.canonical(src_dir));
build_dir = stdlib.posix(stdlib.canonical(build_dir));

assert(isfolder(src_dir), "source directory not found: %s", src_dir)
assert(isfile(fullfile(src_dir, "CMakeLists.txt")), "%s does not contain CMakeLists.txt", src_dir)

assert(system("cmake --version") == 0, 'CMake not found')

%% configure
% don't use ctest -S as it will infinite loop with MSIS build/test
cmd = "cmake -S" + src_dir + " -B" + build_dir + " -DBUILD_TESTING:BOOL=off";
if ~isempty(cmake_args)
  cmd = cmd + " " + cmake_args;
end
if ~isempty(install_dir)
  cmd = cmd + " -DCMAKE_INSTALL_PREFIX:PATH=" + build_dir;
end
if system(cmd) ~= 0
  error("CMake configure %s", src_dir)
end

%% build
cmd = "cmake --build " + build_dir + " --parallel";
if system(cmd) ~= 0
  error('CMake build %s', build_dir)
end

%% install
if ~isempty(install_dir)
  cmd = "cmake --install " + build_dir;

  if system(cmd) ~= 0
    error('CMake install %s', build_dir)
  end
end

end % function
