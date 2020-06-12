function cmake(srcdir, builddir)
% build program using CMake and default generator
% to specify generator with CMake >= 3.15 set environment variable CMAKE_GENERATOR

narginchk(2,2)

%% MacOS workaround
% Matlab does not seem to load .zshrc or otherwise pickup shell "export" like
% Matlab on Linux or Windows does, so we apply these MacOS-specific workaround

env_fix = '';
if ismac
  env_fix = 'export PATH=$PATH:/usr/local/bin &&';
end

ret = system([env_fix,' cmake --version']);
if ret ~= 0
  error('cmake:environment_error', 'CMake not found')
end

%% Windows CMake generator default
% For legacy reasons, CMake on Windows defaults to Visual Studio.
% Visual Studio is not typically useful for Fortran,
% so we default to Ninja or MinGW Makefiles
cmake_gen = '';
if ispc
  if isempty(getenv('CMAKE_GENERATOR'))
    ret = system('ninja --version');
    if ret==0
      cmake_gen = ' -G Ninja';
    else
      cmake_gen = ' -G MinGW Makefiles';
    end
  end
end

ret = system([env_fix,' cmake -S', srcdir, ' -B', builddir, cmake_gen]);
if ret ~= 0
  % maybe we have a prior build from a different compiler,
  % let's try a fresh CMake configuration
  delete(fullfile(builddir, 'CMakeCache.txt'))
  ret = system([env_fix,' cmake -S', srcdir, ' -B', builddir, cmake_gen]);
end
if ret~=0
  error('cmake:runtime_error', 'error configuring with CMake')
end

%ret = system(['cmake --build ',builddir,' --parallel']);
ret = system([env_fix,' cmake --build ',builddir,' --parallel']);
if ret ~= 0
  error('cmake:runtime_error', 'error building with CMake')
end

end % function
