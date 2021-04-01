function mpiexec = check_mpiexec(mpiexec, exe)
arguments
  mpiexec string
  exe (1,1) string
end

if isempty(mpiexec)
  mpi_root = getenv("MPI_ROOT");
  if isempty(mpi_root)
    mpi_root = getenv("I_MPI_ROOT");
  end

  if ~isempty(mpi_root)
    f = fullfile(mpi_root, "bin", "mpiexec");
    if exist(f, "file")
      mpiexec = f;
    end
  end
end
if isempty(mpiexec)
  mpiexec = "mpiexec";
end

[ret, msg] = system(mpiexec + " -help");
if ret ~= 0
  mpiexec = string.empty;
  return
end

if ~ispc
  return
end

% get gemini.bin compiler ID
[~, vendor] = system(exe + " -compiler");
if contains(vendor, 'GNU') && contains(msg, 'Intel(R) MPI Library')
  mpiexec = string.empty;
  warning("Not using MPIexec since MinGW is not compatible with Intel MPI")
end

end % function
