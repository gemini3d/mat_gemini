classdef TestALint < matlab.unittest.TestCase

methods (Test)

function test_linter(tc)
cwd = fileparts(mfilename('fullpath'));
[fail, N] = checkcode_recursive(fullfile(cwd, '..'), tc, fullfile(cwd, "MLint.txt"));

tc.assertGreaterThan(N, 140, "fewer than expected MatGemini3D files to test")
tc.assertFalse(fail)
end

end

end
