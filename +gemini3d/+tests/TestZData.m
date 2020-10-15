classdef TestZData < matlab.unittest.TestCase

properties
TestData
end

methods(TestMethodSetup)
function setup_env(tc)
cwd = fileparts(mfilename('fullpath'));
tc.TestData.cwd = cwd;
tc.TestData.ref_dir = fullfile(cwd, "data");
end
end

methods (Test)

function test_loadframe_standalone_file(tc)
dat = gemini3d.loadframe(fullfile(tc.TestData.ref_dir, "20201234_01234.000000.h5"), "vars", "ne")
end

end

end
