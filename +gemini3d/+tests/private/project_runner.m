function project_runner(tc, name, file_format, ref_dir)
arguments
  tc (1,1) matlab.unittest.TestCase
  name (1,1) string
  file_format (1,1) string
  ref_dir (1,1) string
end

import gemini3d.fileio.download_and_extract
import stdlib.fileio.with_suffix
import stdlib.fileio.path_tail

test_dir = fullfile(ref_dir, name);
%% get files if needed
download_and_extract(name, ref_dir)
%% setup new test data
p = gemini3d.read.config(test_dir);
tc.assumeNotEmpty(p)
p.file_format = file_format;
p.outdir = tc.TestData.outdir;

for k = ["indat_file", "indat_size", "indat_grid"]
  p.(k) = with_suffix(p.(k), "." + file_format);
end
%% patch eq_dir to use reference data
if isfield(p, 'eq_dir')
  eq_dir = fullfile(fileparts(test_dir), path_tail(p.eq_dir));
  if isfolder(eq_dir)
    disp("Using " + eq_dir + " for equilibrium data")
    p.eq_dir = eq_dir;
  end
end

%% generate initial condition files
gemini3d.model.setup(p);
%% check generated files

gemini3d.compare(p.outdir, test_dir, "only", "in", "file_format", file_format)

end  % function
