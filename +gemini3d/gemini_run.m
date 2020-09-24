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
  opts.gemini_exe string = string.empty
  opts.ssl_verify string = string.empty
  opts.file_format string = string.empty
  opts.dryrun (1,1) logical = false
end

%% get gemini.bin executable
exe = gemini3d.get_gemini_exe(opts.gemini_exe);
%% ensure mpiexec is available
[ret, msg] = system(opts.mpiexec + " -help");
assert(ret == 0, 'mpiexec not found')
if ispc
% check that MPIexec matches gemini.bin.exe
[~, vendor] = system(exe + " -compiler");
if contains(vendor, 'GNU') && contains(msg, 'Intel(R) MPI Library')
  error('gemini_run:runtime_error', 'MinGW is not compatible with Intel MPI')
end
end % if ispc
%% check if model needs to be setup
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
    if ~isfile(cfg.(k))
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
%% assemble run command
np = gemini3d.get_mpi_count(fullfile(cfg.outdir, cfg.indat_size));
prepend = gemini3d.sys.modify_path();
cmd = opts.mpiexec + " -n " + int2str(np) + " " + exe + " " +cfg.outdir;
disp(cmd)
cmd = prepend + " " + cmd;
%%% dry run
% py_cmd = py.list(split(cmd)');
% py_dryrun = py_cmd;
% py_dryrun.append('-dryrun')
% py.subprocess.check_call(py_dryrun)

%% dry run
ret = system(cmd + " -dryrun");
if ret~=0
  error('gemini_run:runtime_error', 'Gemini dryrun failed')
end

if opts.dryrun
  return
end
%% run simulation
gemini3d.log_meta_nml(gemini3d.git_revision(fileparts(exe)), ...
                      fullfile(cfg.outdir, "setup_meta.nml"), 'setup_gemini')

ret = system(cmd);
if ret~=0
  error('gemini_run:runtime_error', 'Gemini run failed')
end

end % function
