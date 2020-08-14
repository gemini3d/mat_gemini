function cmake(srcdir)
% build program using CMake and default generator
% to specify generator with CMake >= 3.15 set environment variable CMAKE_GENERATOR

narginchk(1,1)

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

ret = system([env_fix,' ctest -S ', fullfile(srcdir, 'setup.cmake'), ' -VV']);
if ret ~= 0
  error('cmake:runtime_error', 'error building with CMake')
end

end % function
