function gemini_run(outdir, opts)
%% setup and run Gemini simulation
%
% Examples:
%
% gemini3d.gemini_run(output_dir),
% gemini3d.gemini_run(output_dir, "config", nml_path)

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
gemini3d.sys.check_mpiexec(opts.mpiexec, gemini_exe)
%% check if model needs to be setup
cfg = setup_if_needed(opts, outdir);
%% assemble run command
cmd = create_run(cfg, opts.mpiexec, gemini_exe);

if opts.dryrun
  return
end
%% run simulation
gemini3d.log_meta_nml(gemini3d.git_revision(fileparts(gemini_exe)), ...
                      fullfile(cfg.outdir, "setup_meta.nml"), 'setup_gemini')

ret = system(cmd);
if ret ~= 0
  error('gemini_run:runtime_error', 'Gemini run failed, error code %d', ret)
end

end % function


function cfg = setup_if_needed(opts, outdir)
arguments
  opts
  outdir (1,1) string
end

cfg = gemini3d.read_config(opts.config);
cfg.outdir = gemini3d.fileio.expanduser(outdir);

for k = ["ssl_verify", "file_format"]
  if ~isempty(opts.(k))
    cfg.(k) = opts.(k);
  end
end

if opts.overwrite
  % note, if an old, incompatible shape exists this will fail
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

%% close parallel pool
% in case Matlab PCT was invoked for model_setup, shut it down, otherwise too much RAM can
% be wasted while PCT is idle--like several gigabytes.
addons = matlab.addons.installedAddons();
if any(contains(addons.Name, 'Parallel Computing Toolbox'))
  delete(gcp('nocreate'))
end

end % function


function cmd = create_run(cfg, mpiexec, gemini_exe)
arguments
  cfg (1,1) struct
  mpiexec (1,1) string
  gemini_exe (1,1) string
end

np = gemini3d.get_mpi_count(fullfile(cfg.outdir, cfg.indat_size));
prepend = gemini3d.sys.modify_path();
cmd = mpiexec + " -n " + int2str(np) + " " + gemini_exe + " " +cfg.outdir;
disp(cmd)
cmd = prepend + " " + cmd;

%% dry run
ret = system(cmd + " -dryrun");
if ret~=0
  error('gemini_run:runtime_error', 'Gemini dryrun failed')
end

end % function
