% This tests everything, including the test_gemini subset
% Travis-CI doesn't have any easy artifact upload

isCI = getenv("CI") == "true";
isTravisCI = getenv("TRAVIS") == "true";

[runner, suite] = gemini3d.tests.get_suite(~isTravisCI);

gemini3d.tests.run(runner, suite, isCI)
