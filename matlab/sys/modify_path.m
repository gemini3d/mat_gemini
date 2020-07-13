function prepend = modify_path()
% for Octave on Windows, it's necessary to prepend MinGW path
% when running MinGW-compile exectuables
%
% a command is then run like
%
% system([prepend, ' ', 'foo.exe'])

prepend = '';
if isoctave && ispc && ~isempty(getenv('MINGWROOT'))

  syspath = [getenv('MINGWROOT'), pathsep, getenv('PATH')];
  % setenv(syspath)  % does not help
  prepend = ['set PATH=', syspath, ' && '];

elseif ~isoctave && ispc

  addons = matlab.addons.installedAddons();
  if ~any(contains(addons.Name, 'Parallel Computing Toolbox'))
    return
  end

  path_orig = split(getenv('PATH'), ';');
  i = contains(path_orig, 'MATLAB');  % Matlab's MPIexe will fail
  path_new = join(path_orig(~i), ';');

  prepend = ['set PATH=', path_new{1}, ' && '];

end  % if

end % function