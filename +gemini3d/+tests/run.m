function run(runner, suite, isCI)
arguments
  runner (1,1) matlab.unittest.TestRunner
  suite (1,:) matlab.unittest.Test
  isCI (1,1) logical
end

% need to manually start parallel pool for CI
addons = matlab.addons.installedAddons();
if ~isCI && any(contains(addons.Name, 'Parallel Computing Toolbox'))
  results = runInParallel(runner, suite);
else
  results = runner.run(suite);
end

assertSuccess(results)

end
