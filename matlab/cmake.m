function cmake(srcdir, builddir)
% build program using CMake and default generator
% to specify generator with CMake >= 3.15 set environment variable CMAKE_GENERATOR

narginchk(2,2)

ret = system(['cmake --version']);
if ret ~= 0
  error('cmake:environment_error', 'CMake not found')
end

ret = system(['cmake -S', srcdir, ' -B', builddir]);
if ret ~= 0
  delete(fullfile(builddir, 'CMakeCache.txt'))
  ret = system(['cmake -S', srcdir, ' -B', builddir]);
end
if ret~=0
  error('cmake:runtime_error', 'error configuring MSIS')
end

ret = system(['cmake --build ',builddir,' --parallel']);
if ret ~= 0
  error('cmake:runtime_error', 'error building MSIS')
end

end % function
