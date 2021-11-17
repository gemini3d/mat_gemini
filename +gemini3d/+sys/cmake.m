function cmake(src_dir, build_dir)
% build program using CMake and default generator
% specify CMake generator: set environment variable CMAKE_GENERATOR
arguments
  src_dir (1,1) string
  build_dir (1,1) string
end

import stdlib.fileio.posix
import stdlib.fileio.absolute_path

% must be absolute path for Unix-like, where cannot traverse upwards from non-existent dir
% build_dir needs it as well or CMake will use pwd instead
src_dir = posix(absolute_path(src_dir));
build_dir = posix(absolute_path(build_dir));

assert(isfolder(src_dir), "source directory not found: %s", src_dir)
assert(isfile(fullfile(src_dir, "CMakeLists.txt")), "%s does not contain CMakeLists.txt", src_dir)

assert(system("cmake --version") == 0, 'CMake not found')

%% configure
% don't use ctest -S as it will infinite loop with MSIS build/test
cmd = "cmake -S" + src_dir + " -B" + build_dir + " -DBUILD_TESTING:BOOL=off --install-prefix=" + build_dir;
assert(system(cmd) == 0, "error configuring %s with CMake", src_dir)

%% build
cmd = "cmake --build " + build_dir + " --parallel";

ret = system(cmd);
assert(ret == 0, 'error building with CMake in %s', build_dir)

end % function
