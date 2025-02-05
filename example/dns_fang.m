%[text] `This simulation takes less than 1 minute on a typical computer, even a Raspberry Pi.`
%[text] `First we must ensure MatGemini is on the Matlab path:`
cwd = which('gemini3d');
run(fullfile(cwd, 'setup.m'))
%[text] `Pick an arbitrary output directory:`
outdir = '~/simulations/2dns_fang/';
%[text] `Simulation will fail if rerun, so get rid of existing output files first.`
outdir = stdlib.fileio.expanduser(outdir);
filepat = outdir + "/*.h5";
if ~isempty(dir(filepat))
  delete(filepat)
end
%[text] `Now the simulation can be run.`
gemini3d.run(outdir, ...
  fullfile(cwd, 'Examples/init/2dns_fang.nml'), ...
  'overwrite', false)
%[text] Finally, plot the output data.
gemini3d.plot(outdir)

%[appendix]{"version":"1.0"}
%---
%[metadata:view]
%   data: {"layout":"onright","rightPanelPercent":40}
%---
