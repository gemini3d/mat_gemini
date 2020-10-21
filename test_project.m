import matlab.unittest.constraints.ContainsSubstring
import matlab.unittest.selectors.HasName

isCI = getenv("CI") == "true";

[runner, suite] = gemini3d.tests.get_suite(isCI);

suite = suite.selectIf(HasName(ContainsSubstring('Project')));

gemini3d.tests.run(runner, suite, isCI)
