function prepend = octave_mingw_path()
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
end

end % function