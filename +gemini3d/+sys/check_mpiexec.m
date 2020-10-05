function check_mpiexec(mpiexec, exe)
arguments
  mpiexec (1,1) string
  exe (1,1) string
end

[ret, msg] = system(mpiexec + " -help");
if ret ~= 0
  error('gemini_run:file_not_found', 'mpiexec not found')
end

% get gemini.bin compiler ID
[~, vendor] = system(exe + " -compiler");

if ispc && contains(vendor, 'GNU') && contains(msg, 'Intel(R) MPI Library')
  error('gemini_run:runtime_error', 'MinGW is not compatible with Intel MPI')
end

end % function
