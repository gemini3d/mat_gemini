function run(outdir, config_path, opts)
%% setup and run Gemini simulation
%
% Example:
%
% gemini3d.run(output_dir, nml_path)

arguments
  outdir (1,1) string
  config_path (1,1) string
  opts.overwrite (1,1) logical = false
  opts.mpiexec string = "mpiexec"
  opts.gemini_exe (1,1) string = "gemini3d.run"
  opts.ssl_verify string = string.empty
  opts.file_format string = string.empty
  opts.dryrun (1,1) logical = false
end

import stdlib.sys.subprocess_run

%% find or build gemini.bin executable
gemini_exe = gemini3d.sys.get_gemini_exe(opts.gemini_exe);
if isempty(gemini_exe)
  error("Please run setup_gemini3d() to setup Gemini3D")
end
%% check if model needs to be setup
cfg = setup_if_needed(opts, outdir, config_path);
%% check MPIexec
mpiexec = gemini3d.sys.check_mpiexec(opts.mpiexec, gemini_exe);
%% assemble run command
cmd = [gemini_exe, cfg.outdir];
if ~isempty(mpiexec)
  cmd = [cmd, "-mpiexec", '"' + mpiexec + '"'];
end
disp("dryrun: " + join(cmd, " "))
[ret, msg] = subprocess_run([cmd, "-dryrun"]);
if ret ~=0
  error("gemini3d:run:RuntimeError", "Gemini dryrun failed %s", msg)
end

if opts.dryrun
  return
end
%% run simulation
gemini3d.write.meta(fullfile(cfg.outdir, "setup_run.json"), gemini3d.git_revision(fileparts(gemini_exe)), cfg)

disp("run: " + join(cmd, " "))
ret = subprocess_run(cmd);
assert(ret == 0, 'Gemini run failed, error code %d', ret)

end % function
