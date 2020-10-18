function ok = check_mpiexec(mpiexec, exe)
arguments
  mpiexec (1,1) string
  exe (1,1) string
end

[ret, msg] = system(mpiexec + " -help");
ok = ret == 0;
if ~ok
  return
end
% get gemini.bin compiler ID
[~, vendor] = system(exe + " -compiler");

if ispc && contains(vendor, 'GNU') && contains(msg, 'Intel(R) MPI Library')
  ok = false;
  warning("Not using MPIexec since MinGW is not compatible with Intel MPI")
end

end % function
