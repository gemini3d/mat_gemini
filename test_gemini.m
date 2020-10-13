import matlab.unittest.TestSuite
import matlab.unittest.TestRunner
import matlab.unittest.plugins.LoggingPlugin

runner = TestRunner.withNoPlugins;
p = LoggingPlugin.withVerbosity(matlab.unittest.Verbosity.Detailed,...
    'HideLevel',true,'HideTimestamp',true, 'Description', "");
runner.addPlugin(p);

suite = TestSuite.fromPackage('gemini3d.tests');

results = runner.run(suite);
assertSuccess(results)
