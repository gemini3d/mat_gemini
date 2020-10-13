classdef TestProject < matlab.unittest.TestCase
properties (TestParameter)
  file_type = {"h5", "nc"}
  name = {"2dew_eq", "2dew_fang", "2dew_glow", "2dns_eq", "2dns_fang", "2dns_glow", "3d_eq", "3d_fang", "3d_glow"}
end

properties
  TestData
end

methods(TestMethodSetup)
function setup_env(tc)
cwd = fileparts(mfilename('fullpath'));
tc.TestData.cwd = cwd;
tc.TestData.refdir = fullfile(cwd, "data");
% setup so GEMINI_ROOT is set
run(fullfile(cwd, "../../setup.m"))

% temporary working directory
tc.TestData.outdir = tc.applyFixture(matlab.unittest.fixtures.TemporaryFolderFixture('PreservingOnFailure', true)).Folder;

end
end

methods (Test)
function test_runner(tc, file_type, name)
  project_runner(name, file_type, tc.TestData.outdir, tc.TestData.ref_dir)
end
end
end
