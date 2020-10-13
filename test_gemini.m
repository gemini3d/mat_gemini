import matlab.unittest.TestSuite
import matlab.unittest.TestRunner
import matlab.unittest.plugins.LoggingPlugin

runner = TestRunner.withTextOutput;
p = LoggingPlugin.withVerbosity(matlab.unittest.Verbosity.Detailed,...
    'HideLevel',true,'HideTimestamp',true, 'Description', "");
runner.addPlugin(p);

suite = TestSuite.fromPackage('gemini3d.tests');

% under future consideration--need to manually start parallel pool for CI
% addons = matlab.addons.installedAddons();
% if any(contains(addons.Name, 'Parallel Computing Toolbox'))
%   results = runInParallel(runner, suite);
% else
  results = runner.run(suite);
% end

assertSuccess(results)
