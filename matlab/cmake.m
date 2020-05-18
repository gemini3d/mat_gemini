function cmake(srcdir, builddir)
% build program using CMake and default generator
% to specify generator with CMake >= 3.15 set environment variable CMAKE_GENERATOR

narginchk(2,2)

ret = system('cmake --version');
if ret ~= 0
  error('cmake:environment_error', 'CMake not found')
end

tail = '';
if ispc && isempty(getenv('CMAKE_GENERATOR'))
  ret = system('ninja --version');
  if ret==0
    tail = ' -G Ninja';
  else
    tail = ' -G MinGW Makefiles';
  end
end

ret = system(['cmake -S', srcdir, ' -B', builddir, tail]);
if ret ~= 0
  delete(fullfile(builddir, 'CMakeCache.txt'))
  ret = system(['cmake -S', srcdir, ' -B', builddir, tail]);
end
if ret~=0
  error('cmake:runtime_error', 'error configuring with CMake')
end

ret = system(['cmake --build ',builddir,' --parallel']);
if ret ~= 0
  error('cmake:runtime_error', 'error building with CMake')
end

end % function
