function path_new = mpi_path()
% removes conflicts from Path with Matlab MPIexec

path_new = getenv("PATH");

addons = matlab.addons.installedAddons();
if ~any(addons.Name == "Parallel Computing Toolbox")
  return
end

path_orig = split(path_new, ';');
i = contains(path_orig, 'MATLAB');
path_new = string(join(path_orig(~i), ';'));

end
