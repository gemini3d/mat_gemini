classdef TestMagcalc < matlab.unittest.TestCase
properties (TestParameter)
  name = {"mini2dew_fang", "mini2dns_fang", "mini3d_fang"}
end

properties
  TestData
end

methods(TestMethodSetup)
% Method instead of class to allow parallel testing
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
tc.assumeTrue(~isMATLABReleaseOlderThan('R2023a'))
import matlab.unittest.fixtures.EnvironmentVariableFixture

cwd = fileparts(mfilename('fullpath'));

tc.TestData.cwd = cwd;
tc.TestData.ref_dir = fullfile(cwd, "data");

% temporary working directory
tc.TestData.outdir = tc.applyFixture(matlab.unittest.fixtures.TemporaryFolderFixture()).Folder;

fixture = EnvironmentVariableFixture("GEMINI_CIROOT", tc.TestData.outdir);
tc.applyFixture(fixture)

end
end

methods (Test)

function test_magcalc_generate_input(tc, name)

test_dir = fullfile(tc.TestData.ref_dir, name);
%% get files if needed
try
  gemini3d.fileio.download_and_extract(name, tc.TestData.ref_dir)
catch e
  catcher(e, tc)
end

% copy ref directory tree to working directory
copyfile(test_dir, tc.TestData.outdir)

% generate magcalc input files
% arbitrary sizes
Ltheta = 40;
Lphi = 30;
gemini3d.model.magcalc(tc.TestData.outdir, 1.5, Ltheta, Lphi)

%% rudimentary check of file sizes


file = fullfile(tc.TestData.outdir, "inputs/magfieldpoints.h5");
R = h5read(file, "/r");

if contains(name, "3d")
  L = Ltheta * Lphi;
else
  L = Ltheta;
end
tc.verifyEqual(length(R), L, "mismatch grid size magcalc input fieldpoints " + file)


end

end
end
