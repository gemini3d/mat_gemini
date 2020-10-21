function [runner, suite] = get_suite(isCI)
arguments
  isCI (1,1) logical
end

import matlab.unittest.TestSuite
import matlab.unittest.TestRunner
import matlab.unittest.plugins.LoggingPlugin

runner = TestRunner.withTextOutput;
p = LoggingPlugin.withVerbosity(matlab.unittest.Verbosity.Detailed,...
    'HideLevel',true,'HideTimestamp',true, 'Description', "");
runner.addPlugin(p);

addCoverage(runner, isCI)

suite = TestSuite.fromPackage('gemini3d', 'IncludingSubpackages', true);

end
