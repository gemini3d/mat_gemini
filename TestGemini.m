import matlab.unittest.TestRunner
import matlab.unittest.Verbosity
import matlab.unittest.plugins.CodeCoveragePlugin
import matlab.unittest.plugins.XMLPlugin
import matlab.unittest.plugins.codecoverage.CoberturaFormat

name = "gemini3d.tests";

suite = testsuite(name);

runner = TestRunner.withTextOutput('OutputDetail', Verbosity.Concise);

if getenv("CI") == "true"
  mkdir('code-coverage');
  mkdir('test-results');
  runner.addPlugin(XMLPlugin.producingJUnitFormat('test-results/results.xml'));
  runner.addPlugin(CodeCoveragePlugin.forPackage(name, 'Producing', CoberturaFormat('code-coverage/coverage.xml')));
end

results = runner.run(suite);
assert(~isempty(results), "no tests found")

assertSuccess(results)
