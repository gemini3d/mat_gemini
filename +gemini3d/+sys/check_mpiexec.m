function mpiexec = check_mpiexec(mpiexec, exe)
arguments
  mpiexec string {mustBeScalarOrEmpty}
  exe (1,1) string
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

[ret, msg] = system('"' + mpiexec + '"' + " -help");
if ret ~= 0
  mpiexec = string.empty;
  return
end

if ~ispc
  return
end

% get gemini.bin compiler ID
exe = stdlib.which(exe);
if isempty(exe)
  return
end
% get gemini.bin compiler ID
[~, vendor] = system(stdlib.canonical(exe) + " -compiler");
if contains(vendor, 'GNU') && contains(msg, 'Intel(R) MPI Library')
  warning("MinGW is not compatible with Intel MPI %s", mpiexec)
  mpiexec = string.empty;
end

end % function
