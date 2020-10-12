% plots have to be tested here to avoid needing other test state

function tests = test_project_hdf5
tests = functiontests(localfunctions);
end

function setupOnce(tc)
cwd = fileparts(mfilename('fullpath'));
% setup so GEMINI_ROOT is set
run(fullfile(cwd, "../../setup.m"))
end

function setup(tc)
tc.TestData.cwd = fileparts(mfilename("fullpath"));
% temporary working directory
tc.TestData.outdir = tc.applyFixture(matlab.unittest.fixtures.TemporaryFolderFixture('PreservingOnFailure', true)).Folder;
end


function test2dew_eq_h5(tc)
gemini3d.tests.runner('2dew_eq', 'h5', tc.TestData.outdir)
end

function test2dew_fang_h5(tc)
gemini3d.tests.runner('2dew_fang', 'h5', tc.TestData.outdir)
end

function test2dew_glow_h5(tc)
gemini3d.tests.runner('2dew_glow', 'h5', tc.TestData.outdir)
% test 2D plots

h = gemini3d.vis.plotframe(fullfile(tc.TestData.cwd, "data/test2dew_glow"), datetime(2013, 2, 20, 5, 5, 0));
close(h)
end

function test2dns_eq_h5(tc)
gemini3d.tests.runner('2dns_eq', 'h5', tc.TestData.outdir)
end

function test2dns_fang_h5(tc)
gemini3d.tests.runner('2dns_fang', 'h5', tc.TestData.outdir)
end

function test2dns_glow_h5(tc)
gemini3d.tests.runner('2dns_glow', 'h5', tc.TestData.outdir)
end

function test3d_eq_h5(tc)
gemini3d.tests.runner('3d_eq', 'h5', tc.TestData.outdir)
end

function test3d_fang_h5(tc)
gemini3d.tests.runner('3d_fang', 'h5', tc.TestData.outdir)
end

function test3d_glow_h5(tc)
gemini3d.tests.runner('3d_glow', 'h5', tc.TestData.outdir)

% test 3D plots
d3 = fullfile(tc.TestData.cwd, "data/test3d_glow");
h = gemini3d.vis.plotinit(gemini3d.readgrid(d3));
gemini3d.vis.plotframe(d3, datetime(2013, 2, 20, 5, 5, 0), "figures", h)
close(h)
end
