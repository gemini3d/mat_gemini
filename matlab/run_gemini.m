function run_gemini(cfgfile, outdir, gemini_exe)
% consider the full-featured gemini/job.py
narginchk(2,3)

if nargin < 3
  gemini_exe = [];
end

if isoctave
  % NOTE: due to Octave on Windows overriding system MinGW,
  % you may need to compile Gemini.bin with -static option.
  % this was not fixed by addpath(getenv('MINGWROOT'))
  np = idivide(nproc, 2);  % assume hyperthreading
else
  np = maxNumCompThreads;
end
%% get gemini.bin executable
gemini_exe = get_gemini_exe(gemini_exe);
%% ensure mpiexec is available
[ret, ~] = system('mpiexec -help');
assert(ret == 0, 'mpiexec not found')
%% check if model needs to be setup
cfg = read_config(cfgfile);
cfg.outdir = fullfile(outdir, 'inputs');

for k = {'indat_size', 'indat_grid', 'indat_file'}
  if ~isfile(cfg.(k{:}))
    model_setup(cfg)
    break
  end
end
%% assemble run command
prepend = octave_mingw_path();
cmd = sprintf('mpiexec -n %d %s %s %s', np, gemini_exe, cfg.nml, outdir);
disp(cmd)
cmd = [prepend, ' ', cmd];
%% dry run
[ret, msg] = system([cmd, ' -dryrun']);
assert(ret==0, ['Gemini dryrun failed: ', msg])
%% run simulation
ret = system(cmd);
assert(ret==0, 'Gemini run failed')
end % function
