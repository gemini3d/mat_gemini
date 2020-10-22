function [runner, suite] = get_suite(do_coverage)
arguments
  do_coverage (1,1) logical = false
end

import matlab.unittest.TestSuite
import matlab.unittest.TestRunner
import matlab.unittest.plugins.LoggingPlugin

runner = TestRunner.withTextOutput;
p = LoggingPlugin.withVerbosity(matlab.unittest.Verbosity.Detailed,...
    'HideLevel',true,'HideTimestamp',true, 'Description', "");
runner.addPlugin(p);

if do_coverage
  addCoverage(runner)
end

suite = TestSuite.fromPackage('gemini3d', 'IncludingSubpackages', true);

end
