classdef TestDryrun < matlab.unittest.TestCase

properties
  TestData
end

methods(TestMethodSetup)

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

function setup_sim(tc)

exe = gemini3d.find.gemini_exe("gemini3d.run");
tc.assumeNotEmpty(exe, "gemini3d.run program not found. Compile with https://github.com/gemini3d/gemini3d.git")

name = "mini2dew_eq";

cwd = fileparts(mfilename('fullpath'));
tc.TestData.datapath = fullfile(cwd, "data", name);

% get files if needed
try
  gemini3d.fileio.download_and_extract(name, fullfile(cwd, "data"))
catch e
  catcher(e, tc)
end
% temporary working directory
tc.TestData.outdir = tc.applyFixture(matlab.unittest.fixtures.TemporaryFolderFixture()).Folder;
end

end


methods(Test)


function test_dryrun(tc)

try
  gemini3d.run(tc.TestData.outdir, tc.TestData.datapath, "dryrun", true)
catch e
  catcher(e, tc)
end

end
end

end
