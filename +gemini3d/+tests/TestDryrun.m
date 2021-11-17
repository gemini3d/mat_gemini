classdef TestDryrun < matlab.unittest.TestCase

properties
  TestData
end

methods(TestMethodSetup)

function setup_sim(tc)

cwd = fileparts(mfilename('fullpath'));
run(fullfile(cwd, '../../setup.m'))

name = "mini2dew_eq";

cwd = fileparts(mfilename('fullpath'));
tc.TestData.datapath = fullfile(cwd, "data", name);

% get files if needed
gemini3d.fileio.download_and_extract(name, fullfile(cwd, "data"))

% temporary working directory
tc.TestData.outdir = tc.applyFixture(matlab.unittest.fixtures.TemporaryFolderFixture('PreservingOnFailure', true)).Folder;
end

end


methods(Test)

function test_get_gemini_exe(tc)
tc.verifyNotEmpty(gemini3d.sys.get_gemini_exe("gemini3d.run"))
end


function test_dryrun(tc)
gemini3d.run(tc.TestData.outdir, tc.TestData.datapath, 'dryrun', true)
end
end

end
