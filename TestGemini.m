% this script is run on Azure (or local)
import matlab.unittest.constraints.ContainsSubstring
import matlab.unittest.selectors.HasName
import matlab.unittest.TestRunner;
import matlab.unittest.Verbosity;
import matlab.unittest.plugins.CodeCoveragePlugin;
import matlab.unittest.plugins.XMLPlugin;
import matlab.unittest.plugins.codecoverage.CoberturaFormat;

name = "gemini3d.tests";

suite = testsuite(name);
runner = TestRunner.withTextOutput('OutputDetail', Verbosity.Detailed);

if getenv("CI") == "true"
  mkdir('code-coverage');
  mkdir('test-results');
  runner.addPlugin(XMLPlugin.producingJUnitFormat('test-results/results.xml'));
  runner.addPlugin(CodeCoveragePlugin.forPackage(name, 'Producing', CoberturaFormat('code-coverage/coverage.xml')));
else
  % long-running project tests on CI
  suite = suite.selectIf(HasName(~ContainsSubstring('Project')));
end

results = runner.run(suite);
assert(~isempty(results), "no tests found")

nfailed = nnz([results.Failed]);
assert(nfailed == 0, '%d test(s) failed.', nfailed)
