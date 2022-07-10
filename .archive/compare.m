function compare(out_dir, ref_dir, only)
arguments
  out_dir (1,1) string
  ref_dir (1,1) string
  only (1,1) string = ''
end

import matlab.unittest.TestSuite
import matlab.unittest.parameters.Parameter

param = Parameter.fromData('out_dir', {out_dir}, 'ref_dir', {ref_dir}, 'only', {only});

suite = TestSuite.fromClass(?gemini3d.test.TestCompare, 'ExternalParameters', param);

result = suite.run;

assertSuccess(result);
assert(~isempty(result), "no tests found")
assert(result.Incomplete == 0, "test failed to setup")

disp("OK: comparison success: " + out_dir + " vs. " + ref_dir)
end
