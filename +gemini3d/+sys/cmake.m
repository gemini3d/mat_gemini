function cmake(srcdir)
% build program using CMake and default generator
% to specify generator with CMake >= 3.15 set environment variable CMAKE_GENERATOR

narginchk(1,1)

%% MacOS workaround
% Matlab does not seem to load .zshrc or otherwise pickup shell "export" like
% Matlab on Linux or Windows does, so we apply these MacOS-specific workaround

if ismac
  sys_path = ['/usr/local/bin:', getenv('PATH')];
  setenv('PATH', sys_path)
end

ret = system('cmake --version');
if ret ~= 0
  error('cmake:environment_error', 'CMake not found')
end

ret = system(['ctest -S ', fullfile(srcdir, 'setup.cmake'), ' -VV']);
if ret ~= 0
  error('cmake:runtime_error', 'error building with CMake')
end

end % function
