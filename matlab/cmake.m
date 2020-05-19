function cmake(srcdir, builddir)
% build program using CMake and default generator
% to specify generator with CMake >= 3.15 set environment variable CMAKE_GENERATOR

narginchk(2,2)

%> required for matlab 2020a on macOS
pathfix='';
pathfix='export PATH=$PATH:/usr/local/bin &&';

ret = system([pathfix,' cmake --version']);
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

ret = system([pathfix,' cmake -S', srcdir, ' -B', builddir]);
if ret ~= 0
  delete(fullfile(builddir, 'CMakeCache.txt'))
  ret = system([pathfix,' cmake -S', srcdir, ' -B', builddir]);
end
if ret~=0
  error('cmake:runtime_error', 'error configuring with CMake')
end

%ret = system(['cmake --build ',builddir,' --parallel']);
ret = system([pathfix,' cmake --build ',builddir,' --parallel']);
if ret ~= 0
  error('cmake:runtime_error', 'error building with CMake')
end

end % function
