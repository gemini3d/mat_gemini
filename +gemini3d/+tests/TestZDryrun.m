classdef TestZDryrun < matlab.unittest.TestCase

properties
  TestData
end

methods(TestMethodSetup)

function setup_sim(tc)
name = "2dew_eq";

cwd = fileparts(mfilename('fullpath'));
tc.TestData.datapath = fullfile(cwd, "data/test" + name);

% setup so GEMINI_ROOT is set
run(fullfile(cwd, "../../setup.m"))

% get files if needed
gemini3d.fileio.download_and_extract(name, fullfile(cwd, "data"))

% temporary working directory
tc.TestData.outdir = tc.applyFixture(matlab.unittest.fixtures.TemporaryFolderFixture('PreservingOnFailure', true)).Folder;
end

end


methods(Test)
function test_MPIexec(tc)
gemini_exe = gemini3d.sys.get_gemini_exe();
tc.verifyNotEmpty(gemini_exe)
tc.verifyTrue(gemini3d.sys.check_mpiexec("mpiexec", gemini_exe))
end


function test_dry_run(tc)
gemini3d.run(tc.TestData.outdir, tc.TestData.datapath, 'dryrun', true)
end
end

end
