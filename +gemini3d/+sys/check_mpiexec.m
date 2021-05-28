function mpiexec = check_mpiexec(mpiexec, exe)
arguments
  mpiexec string
  exe (1,1) string
end

mpiexec = gemini3d.fileio.which(mpiexec);
if isempty(mpiexec)
  for p = [getenv("I_MPI_ROOT"), getenv("MPI_ROOT")]
    mpiexec = gemini3d.fileio.which("mpiexec", fullfile(p, "bin"));
    if ~isempty(mpiexec)
      break
    end
  end
end
if isempty(mpiexec)
  mpiexec = gemini3d.fileio.which("mpiexec");
end
if isempty(mpiexec)
  return
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
