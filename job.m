function job(cfgfile, outdir)
% note, one should instead use gemini/job.py
narginchk(2,2)

cwd = fileparts(mfilename('fullpath'));
addpath(fullfile(cwd, 'matlab'))

np = maxNumCompThreads;

gemini_root = absolute_path(fullfile(cwd, '../gemini'));
assert(isfolder(gemini_root), 'Gemini3D directory not found')
gemexe = fullfile(gemini_root, 'build/gemini.bin');
if ispc
  gemexe = [gemexe, '.exe'];
end
assert(isfile(gemexe), 'Gemini.bin executable not found')

[ret, ~] = system('mpiexec -help');
assert(ret == 0, 'mpiexec not found')

cfgfile = get_configfile(cfgfile);
%% assemble command
cmd = sprintf('mpiexec -n %d %s %s %s -dryrun', np, gemexe, cfgfile, outdir);
ret = system(cmd);
assert(ret==77, 'Gemini dryrun failed')

end