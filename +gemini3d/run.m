function run(outdir, config_path, opts)
%% setup and run Gemini simulation
%
% Example:
%
% gemini3d.run(output_dir, nml_path)

arguments
  outdir (1,1) string
  config_path (1,1) string
  opts.overwrite (1,1) logical = true
  opts.mpiexec (1,1) string = "mpiexec"
  opts.gemini_exe (1,1) string = gemini3d.sys.gemini_exe_name()
  opts.ssl_verify string = string.empty
  opts.file_format string = string.empty
  opts.dryrun (1,1) logical = false
end

%% ensure all paths are OK
cwd = fileparts(mfilename('fullpath'));
run(fullfile(cwd, '../setup.m'))
%% get gemini.bin executable
gemini_exe = gemini3d.sys.get_gemini_exe(opts.gemini_exe);
%% ensure mpiexec is available
mpiexec_ok = gemini3d.sys.check_mpiexec(opts.mpiexec, gemini_exe);
%% check if model needs to be setup
cfg = setup_if_needed(opts, outdir, config_path);
%% check that no existing simulation is in output directory
% unless this is a milestone restart
if ~isfield(cfg, 'mcadence') || cfg.mcadence < 0
  exist_file = gemini3d.find.frame(outdir, cfg.times(1));
  assert(isempty(exist_file), "a fresh simulation should not have data in output directory: " + outdir)
end

%% assemble run command
cmd = create_run(cfg, opts.mpiexec, gemini_exe, mpiexec_ok);

if opts.dryrun
  return
end
%% run simulation
gemini3d.write.meta(gemini3d.git_revision(fileparts(gemini_exe)), ...
                      fullfile(cfg.outdir, "setup_meta.nml"), 'setup_gemini')

ret = exe_run(cmd, mpiexec_ok);
if ret ~= 0
  error('run:runtime_error', 'Gemini run failed, error code %d', ret)
end

end % function


function cfg = setup_if_needed(opts, outdir, config_path)
arguments
  opts
  outdir (1,1) string
  config_path (1,1) string
end

config_path = gemini3d.fileio.expanduser(config_path);
outdir = gemini3d.fileio.expanduser(outdir);

cfg = gemini3d.read.config(config_path);
assert(~isempty(cfg), "a config.nml file was not found in " + config_path)
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


function cmd = create_run(cfg, mpiexec, gemini_exe, mpiexec_ok)
arguments
  cfg (1,1) struct
  mpiexec (1,1) string
  gemini_exe (1,1) string
  mpiexec_ok (1,1) logical
end

np = gemini3d.sys.get_mpi_count(fullfile(cfg.outdir, cfg.indat_size));

%% mpiexec if available
cmd = gemini_exe + " " + cfg.outdir;
if mpiexec_ok
  cmd = sprintf("%s -n %d %s", mpiexec, np, cmd);
else
  disp("MPIexec not available, falling back to single CPU core execution.")
end

disp(cmd)

%% dry run
ret = exe_run(cmd + " -dryrun", mpiexec_ok);
if ret~=0
  error('run:runtime_error', 'Gemini dryrun failed')
end

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
