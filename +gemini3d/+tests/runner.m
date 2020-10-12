function runner(name, file_format, outdir)
arguments
  name (1,1) string
  file_format (1,1) string
  outdir (1,1) string
end

cwd = fileparts(mfilename('fullpath'));

ref_dir = fullfile(cwd, "data");
test_dir = fullfile(ref_dir, "test" + name);
%% get files if needed
gemini3d.fileio.download_and_extract(name, ref_dir)
%% setup new test data
p = gemini3d.read_config(test_dir);
p.file_format = file_format;
p.outdir = outdir;

for k = ["indat_file", "indat_size", "indat_grid"]
  p.(k) = gemini3d.fileio.with_suffix(p.(k), "." + file_format);
end
%% patch eq_dir to use reference data
if isfield(p, 'eq_dir')
  eq_dir = fullfile(fileparts(test_dir), gemini3d.fileio.path_tail(p.eq_dir));
  if isfolder(eq_dir)
    fprintf('Using %s for equilibrium data \n', eq_dir)
    p.eq_dir = eq_dir;
  end
end

%% generate initial condition files
cp = gemini3d.setup.model_setup(p);
%% check generated files

gemini3d.compare_all(p.outdir, test_dir, "only", "in", "file_format", file_format)

end  % function
