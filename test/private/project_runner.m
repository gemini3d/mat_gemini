function project_runner(tc, name, ref_dir)
arguments
  tc (1,1) matlab.unittest.TestCase
  name (1,1) string
  ref_dir (1,1) string
end

test_dir = fullfile(ref_dir, name);
%% get files if needed
try
  gemini3d.fileio.download_and_extract(name, ref_dir)
catch e
  catcher(e, tc)
end
%% setup new test data
p = gemini3d.read.config(test_dir);
tc.assumeNotEmpty(p)
p.outdir = tc.TestData.outdir;

for k = ["indat_file", "indat_size", "indat_grid"]
  p.(k) = stdlib.with_suffix(p.(k), ".h5");
end
%% patch eq_dir to use reference data
if isfield(p, 'eq_dir')
  [~, n] = fileparts(p.eq_dir);
  eq_dir = stdlib.join(stdlib.parent(test_dir), n);
  if isfolder(eq_dir)
    disp("Using " + eq_dir + " for equilibrium data")
    p.eq_dir = eq_dir;
  end
end

%% generate initial condition files
gemini3d.model.setup(p);

end  % function
