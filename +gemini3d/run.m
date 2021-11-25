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

%% find or build gemini.bin executable
gemini_exe = gemini3d.sys.get_gemini_exe(opts.gemini_exe);
if isempty(gemini_exe)
  src_dir = fullfile(gemini3d.root(), '..');

  gemini3d.sys.cmake(src_dir, fullfile(src_dir, "build"));
  gemini_exe = gemini3d.sys.get_gemini_exe(opts.gemini_exe);
end

assert(~isempty(gemini_exe), "Gemini3D executable not found")
%% check if model needs to be setup
cfg = setup_if_needed(opts, outdir, config_path);
%% check that no existing simulation is in output directory
% unless this is a milestone restart
if ~isfield(cfg, 'mcadence') || cfg.mcadence < 0
  try %#ok<TRYNC>
    gemini3d.find.frame(outdir, cfg.times(1));
    error("gemini3d:run:FileExists", "a fresh simulation should not have data in output directory: %s", outdir)
  end
end

%% check MPIexec
mpiexec = gemini3d.sys.check_mpiexec(opts.mpiexec, gemini_exe);

%% assemble run command
cmd = [gemini_exe, cfg.outdir];
if ~isempty(mpiexec)
  cmd = [cmd, "-mpiexec", '"' + mpiexec + '"'];
end
disp("dryrun: " + join(cmd, " "))
[ret, msg] = stdlib.sys.subprocess_run([cmd, "-dryrun"]);
if ret ~=0
  error("gemini3d:run:RuntimeError", "Gemini dryrun failed %s", msg)
end

if opts.dryrun
  return
end
%% run simulation
gemini3d.write.meta(fullfile(cfg.outdir, "setup_run.json"), gemini3d.git_revision(fileparts(gemini_exe)), cfg)

disp("run: " + join(cmd, " "))
ret = stdlib.sys.subprocess_run(cmd);
assert(ret == 0, 'Gemini run failed, error code %d', ret)

end % function
