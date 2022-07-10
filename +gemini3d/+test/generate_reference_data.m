function generate_reference_data(topdir, outdir, only, opts)
% generate (run) all simulations under topdir
% good to regenerate Zenodo reference data
%
% Parameters
% ----------
%
% topdir: top directory over subdirectories of config.nml
% outdir: top directory to write simulation outputs into from Gemini3D
% only: cell array of simulation names to run
% gemini_exe: full path to Gemini.bin executable
% file_format: 'h5' or 'nc' (defaults to HDF5)
arguments
  topdir (1,1) string
  outdir (1,1) string
  only (1,:) string = string.empty
  opts.overwrite (1,1) logical = true
  opts.gemini_exe string = string.empty
  opts.file_format (1,1) string = "h5"
end

import stdlib.fileio.expanduser

topdir = expanduser(topdir);
outdir = expanduser(outdir);

assert(isfolder(topdir), '%s is not a folder', topdir)

%% run each simulation
names = get_testnames(topdir, only);
assert(~isempty(names), 'No inputs under %s with %s', topdir, only)
disp('Generating data for: ')
disp(names)

for n = names
  gemini3d.run(fullfile(outdir, n), fullfile(topdir, n), ...
    'overwrite', opts.overwrite, 'gemini_exe', opts.gemini_exe, 'file_format', opts.file_format)
end

end % function
