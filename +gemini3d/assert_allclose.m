function testok = assert_allclose(actual, desired, opts)
% testok = assert_allclose(actual, desired, rtol, atol)
%
% Inputs
% ------
% atol: absolute tolerance (scalar)
% rtol: relative tolerance (scalar)
%
% Output
% ------
% testok: logical TRUE if "actual" is close enough to "desired"
%
% based on numpy.testing.assert_allclose
% https://github.com/numpy/numpy/blob/v1.13.0/numpy/core/numeric.py#L2522
%
% if "actual" is within atol OR rtol of "desired", no error is emitted.

arguments
  actual {mustBeNumeric,mustBeNonempty,mustBeFinite}
  desired {mustBeNumeric,mustBeNonempty,mustBeFinite}
  opts.rtol (1,1) double {mustBePositive} = 1e-8
  opts.atol (1,1) double {mustBeNonnegative} = 1e-9
  opts.err_msg (1,1) string = ""
  opts.warnonly (1,1) logical = false
  opts.verbose (1,1) logical = false
end

if opts.warnonly
  efunc = @warning;
else
  efunc = @error;
end

assert(ndims(actual) == ndims(desired), ...
"gemini3d:assert_allclose:shape_error", ...
"%s ndims actual %d /= ndims desired %d", opts.err_msg, ndims(actual), ndims(desired))

desired_shape = size(desired);
actual_shape = size(actual);
if ~all(desired_shape == actual_shape)
  if ismatrix(actual)
    desired = desired.';
  else
    error("gemini3d:assert_allclose:shape_error", "actual shape /= desired shape")
  end
end

%% compare
if isinteger(desired)
  actual = cast(actual, 'like', desired);
end
measdiff = abs(actual-desired);
tol = opts.atol + opts.rtol * abs(desired);
result = measdiff <= tol;

testok = all(result, 'all');

if ~testok
  Nfail = sum(~result, 'all');
  j = find(~result);
  [bigbad,i] = max(measdiff(j), [], 'all');
  i = j(i);
  if opts.verbose
    disp(['error mag.: ',num2str(measdiff(j)')])
    disp(['tolerance:  ',num2str(tol(j)')])
    disp(['Actual:     ',num2str(actual(i))])
    disp(['desired:    ',num2str(desired(i))])
  end

  emsg = "AssertionError: " + opts.err_msg;
  emsg = emsg + " " + num2str(Nfail/numel(desired)*100,'%.2f') + ...
  "% of values failed accuracy. maximum error magnitude " + num2str(bigbad) + " Actual: " + ...
  num2str(actual(i)) + " Desired: " + num2str(desired(i)) + " atol: " + num2str(opts.atol) + ...
  " rtol: " + num2str(opts.rtol);

  efunc(emsg)
end

if nargout==0, clear('testok'), end

end
