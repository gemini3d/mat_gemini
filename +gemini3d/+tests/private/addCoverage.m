function addCoverage(runner)
arguments
  runner (1,1)
end

import matlab.unittest.plugins.CodeCoveragePlugin
import matlab.unittest.plugins.codecoverage.CoberturaFormat


if getenv("CI") == "true"
  reportFile = 'CoverageResults.xml';
  reportFormat = CoberturaFormat(reportFile);
  plugin = CodeCoveragePlugin.forPackage('gemini3d','Producing',reportFormat);
  runner.addPlugin(plugin);
else
  runner.addPlugin(CodeCoveragePlugin.forPackage('gemini3d'))
end

end
