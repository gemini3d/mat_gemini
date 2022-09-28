function path_new = mpi_path()
% removes conflicts from Path with Matlab MPIexec

path_new = getenv("PATH");

if ~gemini3d.sys.has_parallel()
  return
end

path_orig = split(path_new, pathsep);
i = contains(path_orig, 'MATLAB');
path_new = string(join(path_orig(~i), pathsep));

end
