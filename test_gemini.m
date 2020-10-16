import matlab.unittest.TestSuite
import matlab.unittest.TestRunner
import matlab.unittest.plugins.LoggingPlugin
import matlab.unittest.plugins.CodeCoveragePlugin
import matlab.unittest.plugins.codecoverage.CoberturaFormat

runner = TestRunner.withTextOutput;
p = LoggingPlugin.withVerbosity(matlab.unittest.Verbosity.Detailed,...
    'HideLevel',true,'HideTimestamp',true, 'Description', "");
runner.addPlugin(p);

isCI = getenv("CI") == "true";

% coverage
if isCI
% future
reportFile = 'CoverageResults.xml';
reportFormat = CoberturaFormat(reportFile);
% plugin = CodeCoveragePlugin.forPackage('gemini3d','Producing',reportFormat);
% runner.addPlugin(plugin);
else
% works, but saving time
% runner.addPlugin(CodeCoveragePlugin.forPackage('gemini3d'))
end

suite = TestSuite.fromPackage('gemini3d.tests');

% need to manually start parallel pool for CI
addons = matlab.addons.installedAddons();
if ~isCI && any(contains(addons.Name, 'Parallel Computing Toolbox'))
  results = runInParallel(runner, suite);
else
  results = runner.run(suite);
end

assertSuccess(results)
