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
  opts.mpiexec string = string.empty
  opts.gemini_exe (1,1) string = "gemini3d.run"
  opts.ssl_verify string = string.empty
  opts.file_format string = string.empty
  opts.dryrun (1,1) logical = false
end

import stdlib.sys.subprocess_run

%% ensure all paths are OK
cwd = fileparts(mfilename('fullpath'));
run(fullfile(cwd, '../setup.m'))
%% get gemini.bin executable
gemini_exe = gemini3d.sys.get_gemini_exe(opts.gemini_exe);

%% find mpiexec, as it's not necessarily on PATH to avoid MPI library clashes
% mpiexec = gemini3d.sys.check_mpiexec(opts.mpiexec, gemini_exe);

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

%% assemble run command
% cmd = create_run(cfg, ~isempty(mpiexec), gemini_exe);
[ret, msg] = subprocess_run([gemini_exe, cfg.outdir, "-dryrun"]);
if ret ~=0
  error("gemini3d:run:RuntimeError", "Gemini dryrun failed %s", msg)
end

if opts.dryrun
  return
end
%% run simulation
gemini3d.write.meta(fullfile(cfg.outdir, "setup_run.json"), gemini3d.git_revision(fileparts(gemini_exe)), cfg)

ret = subprocess_run([gemini_exe, cfg.outdir]);
assert(ret == 0, 'Gemini run failed, error code %d', ret)

end % function


function cfg = setup_if_needed(opts, outdir, config_path)
arguments
  opts
  outdir (1,1) string
  config_path (1,1) string
end

import stdlib.fileio.expanduser

config_path = expanduser(config_path);
outdir = expanduser(outdir);

cfg = gemini3d.read.config(config_path);
cfg.outdir = outdir;

for k = ["ssl_verify", "file_format"]
  if ~isempty(opts.(k))
    cfg.(k) = opts.(k);
  end
end

if opts.overwrite
  % note, if an old, incompatible shape exists this will fail.
  % we didn't want to automatically recursively delete directories,
  % so it's best to manually ensure all the old directories are removed first.
  gemini3d.model.setup(cfg)
else
  for k = ["indat_size", "indat_grid", "indat_file"]
    if ~isfile(fullfile(cfg.outdir, cfg.(k)))
      gemini3d.model.setup(cfg)
      break
    end
  end
end

end % function


function cmd = create_run(cfg, has_mpi, gemini_exe)
arguments
  cfg (1,1) struct
  has_mpi (1,1) logical
  gemini_exe (1,1) string
end

import stdlib.sys.subprocess_run

cmd = [gemini_exe, cfg.outdir, "-dryrun"];

%% dry run
if ispc && has_mpi
  env = struct("PATH", gemini3d.sys.mpi_path());
else
  env = struct.empty;
end

ret = subprocess_run(cmd, env);

assert(ret == 0, 'Gemini dryrun failed')

end % function


function ret = exe_run(cmd, mpiexec_ok)
% intended to give option to run from py.subprocess if needed
arguments
  cmd (1,1) string
  mpiexec_ok (1,1) logical
end

% p = pyenv;
%
% if ~isempty(p) && gemini3d.version_atleast(p.Version, "3.7")
%   env = py.os.environ;
%   env{"PATH"} = gemini3d.sys.mpi_path();
%   ret =py.subprocess.check_call(cellstr(split(cmd)).', pyargs("env", env));
%
% else
  if mpiexec_ok
    cmd = gemini3d.sys.modify_path() + " " + cmd;
  end
  ret = system(cmd);
% end

 end
