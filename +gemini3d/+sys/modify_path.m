function prepend = modify_path()
% for Octave on Windows, it's necessary to prepend MinGW path
% when running MinGW-compiled executables
% Also, Matlab with Parallel Toolbox MPIEXEC conflicts with system MPIEXEC,
% so excise from Path
%
% a command is then run like
%
% system(prepend + " " + "foo.exe")

prepend = "";

if ~ispc, return, end

% if isoctave && ~isempty(getenv('MINGWROOT'))
%
%   syspath = [getenv('MINGWROOT'), pathsep, getenv('PATH')];
%   % setenv('PATH', syspath)  % does not help
%   prepend = ['set PATH=', syspath, ' && '];
%
% else

path_new = gemini3d.sys.mpi_path();

% setenv('PATH', path_new{1}) % does not help
prepend = "set PATH=" + path_new + " && ";


end % function
