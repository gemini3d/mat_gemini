function assertSuccess(r)
arguments
  r (1,:) matlab.unittest.TestResult
end
assert(~isempty(r), "there were no TestResults")

assert(~any([r.Failed]), message('MATLAB:unittest:TestResult:UnsuccessfulRun'))
end
