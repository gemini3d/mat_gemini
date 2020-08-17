function cmake(srcdir)
% build program using CMake and default generator
% to specify generator with CMake >= 3.15 set environment variable CMAKE_GENERATOR

narginchk(1,1)

ret = system('cmake --version');
if ret ~= 0
  error('cmake:environment_error', 'CMake not found')
end

ret = system(['ctest -S ', fullfile(srcdir, 'setup.cmake'), ' -VV']);
if ret ~= 0
  error('cmake:runtime_error', 'error building with CMake')
end

end % function
