classdef TestZProject < matlab.unittest.TestCase
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
tc.TestData.ref_dir = fullfile(cwd, "data");
% setup so GEMINI_ROOT is set
run(fullfile(cwd, "../../setup.m"))

% temporary working directory
tc.TestData.outdir = tc.applyFixture(matlab.unittest.fixtures.TemporaryFolderFixture('PreservingOnFailure', true)).Folder;

end
end

methods (Test)

function test_Arunner(tc, file_type, name)
  project_runner(name, file_type, tc.TestData.outdir, tc.TestData.ref_dir)
end

function test_plot_2d(tc)
tname = "2dew_glow";
project_runner(tname, 'h5', tc.TestData.outdir, fullfile(tc.TestData.cwd, "data"))

% test 2D plots

h = gemini3d.vis.plotframe(fullfile(tc.TestData.cwd, "data/test" + tname), datetime(2013, 2, 20, 5, 5, 0));
close(h)
end

function test_plot_3d(tc)
tname = '3d_glow';
project_runner(tname, 'h5', tc.TestData.outdir, fullfile(tc.TestData.cwd, "data"))
% test 3D plots
d3 = fullfile(tc.TestData.cwd, "data/test"+tname);
h = gemini3d.vis.plotinit(gemini3d.readgrid(d3));
gemini3d.vis.plotframe(d3, datetime(2013, 2, 20, 5, 5, 0), "figures", h)
close(h)
end

end
end
