% This tests everything, including the test_gemini subset

[runner, suite] = gemini3d.tests.get_suite(true);

gemini3d.tests.run(runner, suite, getenv("CI") == "true")
