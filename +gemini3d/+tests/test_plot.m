function tests = test_plot
tests = functiontests(localfunctions);
end

function setup(tc)

cwd = fileparts(mfilename('fullpath'));
tc.TestData.cwd = cwd;
% setup so GEMINI_ROOT is set
run(fullfile(cwd, "../../setup.m"))

% temporary working directory
tc.TestData.outdir = tc.applyFixture(matlab.unittest.fixtures.TemporaryFolderFixture('PreservingOnFailure', true)).Folder;

end

function test2dew_glow(tc)
gemini3d.tests.runner('2dew_glow', 'h5', tc.TestData.outdir)
% test 2D plots

h = gemini3d.vis.plotframe(fullfile(tc.TestData.cwd, "data/test2dew_glow"), datetime(2013, 2, 20, 5, 5, 0));
close(h)
end

function test3d_glow(tc)
gemini3d.tests.runner('3d_glow', 'h5', tc.TestData.outdir)
% test 3D plots
d3 = fullfile(tc.TestData.cwd, "data/test3d_glow");
h = gemini3d.vis.plotinit(gemini3d.readgrid(d3));
gemini3d.vis.plotframe(d3, datetime(2013, 2, 20, 5, 5, 0), "figures", h)
close(h)
end
