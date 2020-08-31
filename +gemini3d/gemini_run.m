function gemini_run(cfgfile, outdir, gemini_params)
%% setup and run Gemini simulation
% gemini_run('/path/to/config.nml', 'output_dir')
arguments
  cfgfile (1,1) string
  outdir (1,1) string
  gemini_params (1,1) struct = struct()
end

%% defaults
if ~isfield(gemini_params, 'mpiexec') || gemini_params.mpiexec == ""
  gemini_params.mpiexec = 'mpiexec';
end

%% get gemini.bin executable
gemini_exe = gemini3d.get_gemini_exe(gemini_params);
%% ensure mpiexec is available
[ret, msg] = system("mpiexec -help");
assert(ret == 0, 'mpiexec not found')
if ispc
% check that MPIexec matches gemini.bin.exe
[~, vendor] = system(gemini_exe + " -compiler");
if contains(vendor, 'GNU') && contains(msg, 'Intel(R) MPI Library')
  error('gemini_run:runtime_error', 'MinGW is not compatible with Intel MPI')
end
end % if ispc
%% check if model needs to be setup
cfg = gemini3d.read_config(cfgfile);
cfg.outdir = gemini3d.fileio.expanduser(outdir);

for k = ["ssl_verify", "file_format"]
  if isfield(gemini_params, k) && gemini_params.(k) ~= ""
    cfg.(k) = gemini_params.(k);
  end
end

if isfield(gemini_params, 'overwrite') && gemini_params.overwrite
  % note, if an old, incompatible shape exists this will fail
  % we didn't want to automatically recursively delete directories,
  % so it's best to manually ensure all the old directories are removed
  % first.
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
cmd = gemini_params.mpiexec + " -n " + int2str(np) + " " + gemini_exe + " " +cfg.outdir;
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

if isfield(gemini_params, 'dryrun') && gemini_params.dryrun
  return
end
%% run simulation
gemini3d.log_meta_nml(gemini3d.git_revision(fileparts(gemini_exe)), ...
                      fullfile(cfg.outdir, 'setup_meta.nml'), 'setup_gemini')

ret = system(cmd);
if ret~=0
  error('gemini_run:runtime_error', 'Gemini run failed')
end

end % function
