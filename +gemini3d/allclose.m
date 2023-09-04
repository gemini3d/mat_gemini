function close_enough = allclose(actual, desired, opts)
% close_enough = allclose(actual, desired, rtol, atol)
%
% Inputs
% ------
% atol: absolute tolerance (scalar)
% rtol: relative tolerance (scalar)
%
% Output
% ------
% close_enough: logical TRUE if "actual" is close enough to "desired"
%
% based on numpy.testing.assert_allclose
% https://github.com/numpy/numpy/blob/v1.13.0/numpy/core/numeric.py#L2522
%
% if "actual" is within atol OR rtol of "desired", return true
arguments
  actual {mustBeNumeric,mustBeNonempty,mustBeFinite}
  desired {mustBeNumeric,mustBeNonempty,mustBeFinite}
  opts.rtol (1,1) double {mustBePositive} = 1e-8
  opts.atol (1,1) double {mustBeNonnegative} = 1e-9
end

%% compare
if isinteger(desired) && isinteger(actual)
  close_enough = isequal(actual, desired);
  return
end

measdiff = abs(actual-desired);
tol = opts.atol + opts.rtol * abs(desired);

close_enough = all(measdiff <= tol, 'all');

end  % function
