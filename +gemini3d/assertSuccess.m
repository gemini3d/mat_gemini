function assertSuccess(r)
assert(~isempty(r), "there were no TestResults")

assert(~any([r.Failed]), message('MATLAB:unittest:TestResult:UnsuccessfulRun'))
end
