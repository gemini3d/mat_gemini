classdef TestDryrun < matlab.unittest.TestCase

properties
  TestData
end

methods(TestMethodSetup)

function setup_sim(tc)

name = "mini2dew_eq";

cwd = fileparts(mfilename('fullpath'));
tc.TestData.datapath = fullfile(cwd, "data", name);

% get files if needed
gemini3d.fileio.download_and_extract(name, fullfile(cwd, "data"))

% temporary working directory
tc.TestData.outdir = tc.applyFixture(matlab.unittest.fixtures.TemporaryFolderFixture(PreservingOnFailure=true)).Folder;
end

end


methods(Test)


function test_dryrun(tc)

try
  gemini3d.run(tc.TestData.outdir, tc.TestData.datapath, dryrun=true)
catch e
  if contains(e.message, "HDF5 library version mismatched error")
    tc.assumeFail("HDF5 shared library conflict Matlab <=> system")
  elseif contains(e.message, "GLIBCXX")
    tc.assumeFail("conflict in libstdc++ Matlab <=> system")
  else
    rethrow(e)
  end
end

end
end

end
