function cmake(src_dir, build_dir)
% build program using CMake and default generator
% to specify generator with CMake >= 3.15 set environment variable CMAKE_GENERATOR
arguments
  src_dir (1,1) string
  build_dir (1,1) string
end

ret = system('cmake --version');
if ret ~= 0
  error('cmake:environment_error', 'CMake not found')
end

% don't use ctest -S as it will infinite loop with MSIS build/test
ret = system("cmake -S" + src_dir + " -B" + build_dir + " -DBUILD_TESTING:BOOL=off");
if ret ~= 0
  error('cmake:runtime_error', 'error configuring MSIS with CMake')
end

ret = system("cmake --build " + build_dir);
if ret ~= 0
  error('cmake:runtime_error', 'error building MSIS with CMake')
end

end % function
