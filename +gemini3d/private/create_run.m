function cmd = create_run(cfg, has_mpi, gemini_exe)
arguments
  cfg (1,1) struct
  has_mpi (1,1) logical
  gemini_exe (1,1) string
end

cmd = [gemini_exe, cfg.outdir, "-dryrun"];

%% dry run
if ispc && has_mpi
  env = struct("PATH", gemini3d.sys.mpi_path());
else
  env = struct.empty;
end

ret = stdlib.subprocess_run(cmd, env);

assert(ret == 0, 'Gemini dryrun failed')

end % function
