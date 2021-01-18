function prepend = modify_path()
% Matlab with Parallel Toolbox MPIEXEC conflicts with system MPIEXEC,
% so excise from Path
%
% a command is then run like
%
% system(prepend + " " + "foo.exe")

prepend = "";

if ~ispc, return, end

path_new = gemini3d.sys.mpi_path();

% setenv('PATH', path_new{1}) % does not help
prepend = "set PATH=" + path_new + " && ";

end % function
