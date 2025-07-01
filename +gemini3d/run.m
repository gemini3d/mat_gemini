%% RUN setup and run Gemini3D simulation
%
% Example:
%
%   gemini3d.run(output_dir, nml_path)

function run(outdir, config_path, opts)
arguments
  outdir (1,1) string
  config_path (1,1) string
  opts.overwrite (1,1) logical = false
  opts.mpiexec string = "mpiexec"
  opts.gemini_exe (1,1) string = "gemini3d.run"
  opts.ssl_verify string = string.empty
  opts.dryrun (1,1) logical = false
end

gemini3d.sys.check_stdlib()

%% find gemini.bin executable
gemini_exe = gemini3d.find.gemini_exe(opts.gemini_exe);
assert(~isempty(gemini_exe), "gemini3d:run:file_not_found", ...
  "Please setup Gemini3D. Set environment variable GEMINI_ROOT to the directory over bin/gemini.bin")
%% check if model needs to be setup
cfg = setup_if_needed(opts, outdir, config_path);

cmd = gemini_cmd(gemini_exe, cfg.outdir, opts.mpiexec);

dryrun(cmd)

if opts.dryrun
  return
end
%% run simulation
gemini3d.write.meta(fullfile(cfg.outdir, "setup_run.json"), gemini3d.git_revision(fileparts(gemini_exe)), cfg)

disp("run: " + join(cmd, " "))
ret = stdlib.subprocess_run(cmd);
assert(ret == 0, "gemini3d:run:RuntimeError", 'Gemini run failed, error code %d', ret)

end % function


function cmd = gemini_cmd(exe, outdir, mpi_exe)

cmd = [exe, outdir];
mpiexec = gemini3d.sys.check_mpiexec(mpi_exe, exe);
if ~isempty(mpiexec)
  cmd = [cmd, "-mpiexec", '"' + mpiexec + '"'];
end

end


function dryrun(cmd)

cmd = [cmd, "-dryrun"];

scmd = join(cmd, " ");
disp("dryrun: " + scmd)
% [ret, stdout, stderr] = stdlib.subprocess_run(cmd);
% msg = stdout + stderr;
[ret, msg] = system(scmd);
if ret == 0
  % check for operating system failure that returned 0 but did nothing or failed
  assert(any(contains(msg, "OK: Gemini dry run")), cmd(1) + " didn't run correctly." + msg)
elseif ret == -1073741515
  % Windows 0xc0000135, missing DLL
  msg = msg + " On Windows, it's best to build Gemini3D with static libraries--including all numeric libraries " + ...
    "such as LAPACK. " + ...
    "A DLL is missing on your system and gemini.bin cannot run." + ...
    "This can also happen if Gemini3D was built with oneAPI and you're not currently in the oneAPI Command Prompt.";
   error("gemini3d:run:RuntimeError", "Gemini dryrun failed %s", msg)
else
  error("gemini3d:run:RuntimeError", "Gemini dryrun failed %d %s", ret, msg)
end

end
