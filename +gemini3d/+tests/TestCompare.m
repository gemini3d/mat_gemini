classdef TestCompare < matlab.unittest.TestCase
% this is a test class meant from use from gemini3d.compare with external parameters
properties (TestParameter)
  % leave empty for overwrite by ExternalParamter
  out_dir = {''};
  ref_dir = {''};
  only = {''};
end


methods (Test)

function test_compare(tc, out_dir, ref_dir, only)

tc.assumeNotEmpty(out_dir, "this test for use by external parameters only")
tc.assumeNotEmpty(ref_dir, "this test for use by external parameters only")

compare_all(tc, out_dir, ref_dir, 'only', only)

end

end

end
