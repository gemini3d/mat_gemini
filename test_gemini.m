% this runs a subset of tests, skipping the longer running "project" tests
% this is adequate for most users, as "test_all" is run on CI and by devs
import matlab.unittest.constraints.ContainsSubstring
import matlab.unittest.selectors.HasName

isCI = getenv("CI") == "true";

[runner, suite] = gemini3d.tests.get_suite();

suite = suite.selectIf(HasName(~ContainsSubstring('Project')));

gemini3d.tests.run(runner, suite, isCI)
