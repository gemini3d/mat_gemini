classdef TestProject < matlab.unittest.TestCase
properties (TestParameter)
  name = {"mini2dew_eq", "mini2dew_fang", "mini2dew_glow", ...
          "mini2dns_eq", "mini2dns_fang", "mini2dns_glow", ...
          "mini3d_eq", "mini3d_fang", "mini3d_glow"}
end

properties
  cwd = fileparts(mfilename('fullpath'))
  ref_dir
  outdir
end

methods(TestClassSetup)

function check_stdlib(tc)
try
  gemini3d.sys.check_stdlib()
catch e
  tc.fatalAssertFail(e.message)
end
end

function check_root(tc)
try
  gemini3d.root();
catch e
  tc.fatalAssertFail(e.message)
end
end

function setup_env(tc)
tc.assumeFalse(isMATLABReleaseOlderThan('R2023a'))
import matlab.unittest.fixtures.EnvironmentVariableFixture

tc.ref_dir = fullfile(tc.cwd, "data");

tc.outdir = tc.createTemporaryFolder();

fixture = EnvironmentVariableFixture("GEMINI_CIROOT", tc.outdir);
tc.applyFixture(fixture)

end
end

methods (Test, TestTags="unit")

function test_cartesian_grid(tc)

tname = "mini2dew_fang";

test_dir = fullfile(tc.ref_dir, tname);
%% get files if needed
try
  gemini3d.fileio.download_and_extract(tname, tc.ref_dir)
catch e
  catcher(e, tc)
end
%% setup new test data
cfg = gemini3d.read.config(test_dir);
xg = gemini3d.grid.cartesian(cfg);

% path patch
cfg.outdir = tc.outdir;
cfg.indat_size = fullfile(cfg.outdir, cfg.indat_size);
cfg.indat_grid = fullfile(cfg.outdir, cfg.indat_grid);

try
  gemini3d.write.grid(cfg, xg);
catch e
  if e.identifier == "gemini3d:write:grid:allclose_error"
    tc.verifyFail("gemini3d.write.grid data mismatch")
  end
end

try
  gemini3d.compare(cfg.indat_grid, test_dir, only="grid")
catch e
  if e.identifier == "gemini3d:compare:grid:allclose_error"
    tc.verifyFail("gemini3d.compare.grid data mismatch")
  end
end
end

function test_Efield(tc)

tname = "mini2dew_fang";

test_dir = fullfile(tc.ref_dir, tname);
%% get files if needed
try
  gemini3d.fileio.download_and_extract(tname, tc.ref_dir)
catch e
  catcher(e, tc)
end
%% setup new test data
p = gemini3d.read.config(test_dir);
tc.assumeNotEmpty(p, test_dir + " not contain config.nml")
E0_dir = p.E0_dir;
p.E0_dir = fullfile(tc.outdir, p.E0_dir);

xg = gemini3d.read.grid(test_dir);

gemini3d.efield.Efield_BCs(p, xg);

time = p.times(1):seconds(p.dtE0):p.times(end);
gemini3d.compare(fullfile(tc.outdir, E0_dir), fullfile(test_dir, E0_dir), only='efield', time=time)
end


function test_precip(tc)

tname = "mini2dew_fang";

test_dir = fullfile(tc.ref_dir, tname);
%% get files if needed
try
  gemini3d.fileio.download_and_extract(tname, tc.ref_dir)
catch e
  catcher(e, tc)
end
%% setup new test data
p = gemini3d.read.config(test_dir);
prec_dir = p.prec_dir;
p.prec_dir = fullfile(tc.outdir, p.prec_dir);

xg = gemini3d.read.grid(test_dir);

gemini3d.particles.particles_BCs(p, xg);

try
  gemini3d.compare(fullfile(tc.outdir, prec_dir), fullfile(test_dir, prec_dir), only="precip", time=p.times)
catch e
  if e.identifier == "gemini3d:compare:precip:allclose_error"
    tc.verifyFail("precipitation data didn't match reference")
  else
    rethrow(e)
  end
end
end

end


methods (Test, TestTags="gemini")

function test_gemini3d_run(tc, name)

try
  project_runner(tc, name, tc.ref_dir)
catch err
  catcher(err, tc)
end

try
  gemini3d.compare(tc.outdir, fullfile(tc.ref_dir, name), only="in")
catch e
  if e.identifier == "gemini3d:compare:input:allclose_error"
    tc.verifyFail("generated plasma data didn't match reference")
elseif e.identifier == "gemini3d:compare:output:allclose_error"
   tc.verifyFail("simulated plasma data didn't match reference")
  elseif e.identifier == "gemini3d:compare:precip:allclose_error"
   tc.verifyFail("generated precipitation data didn't match reference")
  elseif e.identifier == "gemini3d:compare:efield:allclose_error"
   tc.verifyFail("generated E-field data didn't match reference")
  else
    rethrow(e)
  end
end

end

end

methods (Test, TestTags=["gemini", "plot"])

function test_plot_2d(tc)

tname = "mini2dew_glow";

gemini3d.fileio.download_and_extract("mini2dew_eq", tc.ref_dir)
% need equil sim check to avoid race condition

project_runner(tc, tname, tc.ref_dir)

data_dir = fullfile(tc.cwd, "data", tname);

% test 2D plots
h = gemini3d.plot.frame(data_dir, datetime(2013, 2, 20, 5, 5, 0));
tc.verifySize(h, [1,10])
tc.verifyClass(h, 'matlab.ui.Figure')
close(h)

% test grid plot

h = gemini3d.plot.grid(data_dir);
tc.verifySize(h, [1, 4])
tc.verifyClass(h, 'matlab.ui.Figure')
close(h)
end

function test_plot_3d(tc)

tname = 'mini3d_glow';

gemini3d.fileio.download_and_extract("mini3d_eq", tc.ref_dir)
% need equil sim check to avoid race condition

project_runner(tc, tname, tc.ref_dir)

% test 3D plots
d3 = fullfile(tc.cwd, "data", tname);
h = gemini3d.plot.init(gemini3d.read.grid(d3));

tc.verifySize(h, [1,10])
tc.verifyClass(h, 'matlab.ui.Figure')

gemini3d.plot.frame(d3, datetime(2013, 2, 20, 5, 5, 0), figures=h)
close(h)
end

end
end
