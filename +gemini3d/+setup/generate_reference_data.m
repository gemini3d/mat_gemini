function generate_reference_data(topdir, outdir, only, gemini_exe, file_format)
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
  only (1,:) string = string([])
  gemini_exe (1,1) string = ""
  file_format (1,1) string = ""
end

topdir = gemini3d.fileio.expanduser(topdir);
outdir = gemini3d.fileio.expanduser(outdir);

assert(isfolder(topdir), '%s is not a folder', topdir)

%% run each simulation
names = gemini3d.get_testnames(topdir, only);
assert(~isempty(names), 'No inputs under %s with %s', topdir, only)
disp('Generating data for: ')
disp(names)

gem_params = struct('overwrite', true, 'mpiexec', "",...
    'file_format', file_format, 'gemini_exe', gemini_exe);

for n = names
  gemini3d.gemini_run(fullfile(topdir, n), fullfile(outdir, n), gem_params)
end

end % function
