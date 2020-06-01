function run_gemini(cfgfile, outdir)
% consider the full-featured gemini/job.py
narginchk(2,2)

cwd = fileparts(mfilename('fullpath'));
addpath(cwd)

if isoctave
  % NOTE: due to Octave on Windows overriding system MinGW,
  % you may need to compile Gemini.bin with -static option.
  % this was not fixed by addpath(getenv('MINGWROOT'))
  np = idivide(nproc, 2);  % assume hyperthreading
else
  np = maxNumCompThreads;
end
%% get gemini.bin executable
gemini_root = getenv('GEMINI_ROOT');
if isempty(gemini_root)
  gemini_root = absolute_path(fullfile(cwd, '../gemini'));
end
assert(isfolder(gemini_root), 'Gemini3D directory not found')
gemexe = fullfile(gemini_root, 'build/gemini.bin');
if ispc
  gemexe = [gemexe, '.exe'];
end
assert(isfile(gemexe), 'Gemini.bin executable not found')
%% ensure mpiexec is available
[ret, ~] = system('mpiexec -help');
assert(ret == 0, 'mpiexec not found')
%% assemble command
cfgfile = get_configfile(cfgfile);
cmd = sprintf('mpiexec -n %d %s %s %s', np, gemexe, cfgfile, outdir);
disp(cmd)
%% sanity check gemini.bin executable
ret = system(gemexe);
assert(ret==77, ['problem with ', gemexe])
%% dry run
ret = system([cmd, ' -dryrun']);
assert(ret==77, 'Gemini dryrun failed')
%% run simulation
ret = system(cmd);
assert(ret==0, 'Gemini run failed')
end % function