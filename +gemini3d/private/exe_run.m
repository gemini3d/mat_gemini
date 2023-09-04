function ret = exe_run(cmd, mpiexec_ok)
% exe_run  run a command with path modified for MPIexec on Windows
arguments
  cmd (1,1) string
  mpiexec_ok (1,1) logical
end

if ispc && mpiexec_ok
  cmd = gemini3d.sys.modify_path() + " " + cmd;
end

ret = system(cmd);

end
