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

% temporary working directory
tc.TestData.outdir = tc.applyFixture(matlab.unittest.fixtures.TemporaryFolderFixture('PreservingOnFailure', true)).Folder;

end
end

methods (Test)

function test_grid(tc)
  tol.rtol = 1e-5;
  tol.atol = 1e-4;
  tname = "2dew_fang";

  test_dir = fullfile(tc.TestData.ref_dir, "test" + tname);
  %% get files if needed
  gemini3d.fileio.download_and_extract(tname, tc.TestData.ref_dir)
  %% setup new test data
  cfg = gemini3d.read_config(test_dir);
  xg = gemini3d.setup.gridgen.makegrid_cart_3D(cfg);

  % path patch
  cfg.outdir = tc.TestData.outdir;
  cfg.indat_size = fullfile(cfg.outdir, cfg.indat_size);
  cfg.indat_grid = fullfile(cfg.outdir, cfg.indat_grid);
  gemini3d.writegrid(cfg, xg);

  compare_grid(tc, cfg.indat_grid, test_dir, tol)
end

function test_Efield(tc)
  tname = "2dew_fang";

  test_dir = fullfile(tc.TestData.ref_dir, "test" + tname);
  %% get files if needed
  gemini3d.fileio.download_and_extract(tname, tc.TestData.ref_dir)
  %% setup new test data
  p = gemini3d.read_config(test_dir);
  E0_dir = p.E0_dir;
  p.E0_dir = fullfile(tc.TestData.outdir, p.E0_dir);

  xg = gemini3d.readgrid(test_dir);

  gemini3d.setup.Efield_BCs(p, xg);

  compare_efield(tc, p.times, ...
    fullfile(tc.TestData.outdir, E0_dir), ...
    fullfile(test_dir, E0_dir), ...
    'rel', 0.001, 'abs', 0.01)
end


function test_precip(tc)
  tname = "2dew_fang";

  test_dir = fullfile(tc.TestData.ref_dir, "test" + tname);
  %% get files if needed
  gemini3d.fileio.download_and_extract(tname, tc.TestData.ref_dir)
  %% setup new test data
  p = gemini3d.read_config(test_dir);
  prec_dir = p.prec_dir;
  p.prec_dir = fullfile(tc.TestData.outdir, p.prec_dir);

  xg = gemini3d.readgrid(test_dir);

  gemini3d.setup.particles_BCs(p, xg);

  compare_precip(tc, p.times, ...
    fullfile(tc.TestData.outdir, prec_dir), ...
    fullfile(test_dir, prec_dir), ...
    'rel', 0.001, 'abs', 0.01)
end

function test_Arunner(tc, file_type, name)
  project_runner(tc, name, file_type, tc.TestData.ref_dir)
end

function test_plot_2d(tc)
tname = "2dew_glow";
project_runner(tc, tname, 'h5', fullfile(tc.TestData.cwd, "data"))

data_dir = fullfile(tc.TestData.cwd, "data/test" + tname);
% test 2D plots

h = gemini3d.vis.plotframe(data_dir, datetime(2013, 2, 20, 5, 5, 0));
tc.verifySize(h, [1,10])
tc.verifyClass(h, 'matlab.ui.Figure')
close(h)

% test grid plot

h = gemini3d.plot_grid(data_dir);
tc.verifySize(h, [1, 1])
tc.verifyClass(h, 'matlab.ui.Figure')
close(h)
end

function test_plot_3d(tc)
tname = '3d_glow';
project_runner(tc, tname, 'h5', fullfile(tc.TestData.cwd, "data"))
% test 3D plots
d3 = fullfile(tc.TestData.cwd, "data/test"+tname);
h = gemini3d.vis.plotinit(gemini3d.readgrid(d3));

tc.verifySize(h, [1,10])
tc.verifyClass(h, 'matlab.ui.Figure')

gemini3d.vis.plotframe(d3, datetime(2013, 2, 20, 5, 5, 0), "figures", h)
close(h)
end

end
end
