name = "2dew_eq";

cwd = fileparts(mfilename('fullpath'));
% setup so GEMINI_ROOT is set
run(fullfile(cwd, "../../setup.m"))
% get files if needed
gemini3d.fileio.download_and_extract(name, fullfile(cwd, "data"))
%% MPIexec
gemini_exe = gemini3d.sys.get_gemini_exe();
gemini3d.sys.check_mpiexec("mpiexec", gemini_exe)
%% dry run
outdir = fullfile(tempdir, name);
if isfolder(outdir)
rmdir(outdir, 's')
end

gemini3d.gemini_run(outdir, ...
  'config', "+gemini3d/+tests/data/test" + name, ...
  'dryrun', true)
