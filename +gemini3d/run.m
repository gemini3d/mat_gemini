function run(outdir, opts)
%% setup and run Gemini simulation
%
% Examples:
%
% gemini3d.run(output_dir),
% gemini3d.run(output_dir, "config", nml_path)

arguments
  outdir (1,1) string
  opts.config (1,1) string = pwd
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
cfg = setup_if_needed(opts, outdir);
%% assemble run command
cmd = create_run(cfg, opts.mpiexec, gemini_exe, mpiexec_ok);

if opts.dryrun
  return
end
%% run simulation
log_meta_nml(git_revision(fileparts(gemini_exe)), ...
                      fullfile(cfg.outdir, "setup_meta.nml"), 'setup_gemini')

ret = system(cmd);
if ret ~= 0
  error('run:runtime_error', 'Gemini run failed, error code %d', ret)
end

end % function


function cfg = setup_if_needed(opts, outdir)
arguments
  opts
  outdir (1,1) string
end

cfg = gemini3d.read_config(opts.config);
if isempty(cfg)
  error("run:file_not_found", "a config.nml file was not found in %s. Try specifying gemini3d.run(outdir, 'config', 'path/to/config.nml')", opts.config)
end

cfg.outdir = gemini3d.fileio.expanduser(outdir);

for k = ["ssl_verify", "file_format"]
  if ~isempty(opts.(k))
    cfg.(k) = opts.(k);
  end
end

if opts.overwrite
  % note, if an old, incompatible shape exists this will fail.
  % we didn't want to automatically recursively delete directories,
  % so it's best to manually ensure all the old directories are removed first.
  gemini3d.setup.model_setup(cfg)
else
  for k = ["indat_size", "indat_grid", "indat_file"]
    if ~isfile(fullfile(cfg.outdir, cfg.(k)))
      gemini3d.setup.model_setup(cfg)
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
cmd = gemini_exe + " " +cfg.outdir;
if mpiexec_ok
  cmd = mpiexec + " -n " + int2str(np) + " " + cmd;
else
  warning("MPIexec not available, falling back to single CPU core execution.")
end

disp(cmd)

if mpiexec_ok
  cmd = gemini3d.sys.modify_path() + " " + cmd;
end

%% dry run
ret = system(cmd + " -dryrun");
if ret~=0
  error('run:runtime_error', 'Gemini dryrun failed')
end

end % function
