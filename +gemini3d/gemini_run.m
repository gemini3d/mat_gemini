function gemini_run(cfgfile, outdir, gemini_params)
%% setup and run Gemini simulation
% gemini_run('/path/to/config.nml', 'output_dir')

narginchk(2, 3)

%% defaults
if nargin < 3
  gemini_params = struct();
end
validateattributes(gemini_params, {'struct'}, {'scalar'})
if ~isfield(gemini_params, 'mpiexec') || isempty(gemini_params.mpiexec)
  gemini_params.mpiexec = 'mpiexec';
end

%% get gemini.bin executable
gemini_exe = gemini3d.get_gemini_exe(gemini_params);
%% ensure mpiexec is available
[ret, msg] = system('mpiexec -help');
assert(ret == 0, 'mpiexec not found')
if ispc
% check that MPIexec matches gemini.bin.exe
[~, vendor] = system([gemini_exe, ' -compiler']);
if contains(vendor, 'GNU') && contains(msg, 'Intel(R) MPI Library')
  error('gemini_run:runtime_error', 'MinGW is not compatible with Intel MPI')
end
%% check if model needs to be setup
cfg = gemini3d.read_config(cfgfile);
cfg.outdir = gemini3d.fileio.expanduser(outdir);

if isfield(gemini_params, 'file_format') && ~isempty(gemini_params.file_format)
  cfg.file_format = gemini_params.file_format;
end

if isfield(gemini_params, 'overwrite') && gemini_params.overwrite
  % note, if an old, incompatible shape exists this will fail
  % we didn't want to automatically recursively delete directories,
  % so it's best to manually ensure all the old directories are removed
  % first.
  gemini3d.setup.model_setup(cfg)
else
  for k = {'indat_size', 'indat_grid', 'indat_file'}
    if ~gemini3d.fileio.is_file(cfg.(k{:}))
      gemini3d.setup.model_setup(cfg)
      break
    end
  end
end

%% close parallel pool
% in case Matlab PCT was invoked for model_setup, shut it down, otherwise too much RAM can
% be wasted while PCT is idle--like several gigabytes.
delete(gcp('nocreate'))

%% assemble run command
np = gemini3d.get_mpi_count(fullfile(cfg.outdir, cfg.indat_size));
prepend = gemini3d.sys.modify_path();
cmd = sprintf('%s -n %d %s %s', gemini_params.mpiexec, np, gemini_exe, cfg.outdir);
disp(cmd)
cmd = [prepend, ' ', cmd];
%%% dry run
% py_cmd = py.list(split(cmd)');
% py_dryrun = py_cmd;
% py_dryrun.append('-dryrun')
% py.subprocess.check_call(py_dryrun)

%% dry run
ret = system([cmd, ' -dryrun']);
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
