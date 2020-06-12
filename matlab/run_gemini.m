function run_gemini(cfgfile, outdir, gemini_exe, gemini_params)
% consider the full-featured gemini/job.py
narginchk(2, 4)

%% defaults
if nargin < 3
  gemini_exe = [];
end
if nargin < 4
  gemini_params = struct('overwrite', false, 'mpiexec', 'mpiexec');
end
validateattributes(gemini_params, {'struct'}, {'scalar'})
if ~isfield(gemini_params, 'mpiexec') || isempty(gemini_params.mpiexec)
  gemini_params.mpiexec = 'mpiexec';
end

%% get gemini.bin executable
gemini_exe = get_gemini_exe(gemini_exe);
%% ensure mpiexec is available
[ret, ~] = system('mpiexec -help');
assert(ret == 0, 'mpiexec not found')
%% check if model needs to be setup
cfg = read_config(cfgfile);
cfg.outdir = fullfile(outdir, 'inputs');

if gemini_params.overwrite
  % note, if an old, incompatible shape exists this will fail
  % we didn't want to automatically recursively delete directories,
  % so it's best to manually ensure all the old directories are removed
  % first.
  model_setup(cfg)
else
  for k = {'indat_size', 'indat_grid', 'indat_file'}
    if ~is_file(cfg.(k{:}))
      model_setup(cfg)
      break
    end
  end
end
%% assemble run command
np = get_mpi_count(fullfile(outdir, cfg.indat_size));
prepend = octave_mingw_path();
cmd = sprintf('%s -n %d %s %s %s', gemini_params.mpiexec, np, gemini_exe, cfg.nml, outdir);
disp(cmd)
cmd = [prepend, ' ', cmd];
%% dry run
[ret, msg] = system([cmd, ' -dryrun']);
assert(ret==0, ['Gemini dryrun failed: ', msg])
%% run simulation
ret = system(cmd);
assert(ret==0, 'Gemini run failed')
end % function
