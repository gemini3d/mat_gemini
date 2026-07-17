function mpiexec = check_mpiexec(mpiexec)
arguments
  mpiexec string {mustBeScalarOrEmpty}
end

mpiexec = stdlib.which(mpiexec);
if isempty(mpiexec)
  for p = [string(getenv("I_MPI_ROOT")), string(getenv("MPI_ROOT"))]
    if strlength(p) == 0
      continue
    end
    mpiexec = stdlib.which("mpiexec", fullfile(p, "bin"));
    if ~isempty(mpiexec)
      break
    end
  end
end
if isempty(mpiexec)
  mpiexec = stdlib.which("mpiexec");
end
if isempty(mpiexec)
  return
end

[ret, ~] = system('"' + mpiexec + '"' + " -help");
if ret ~= 0
  mpiexec = string.empty;
  return
end

end
