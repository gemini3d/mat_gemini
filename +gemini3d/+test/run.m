function run(runner, suite, isCI, parallel)
arguments
  runner (1,1) matlab.unittest.TestRunner
  suite (1,:) matlab.unittest.Test
  isCI (1,1) logical
  parallel (1,1) logical = true
end

% need to manually start parallel pool for CI
if parallel && ~isCI && gemini3d.sys.has_parallel()
  results = runInParallel(runner, suite);
else
  results = runner.run(suite);
end

assertSuccess(results)

end
