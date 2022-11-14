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
% for Matlab and GNU Octave
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

% Copyright 2020 Michael Hirsch, Ph.D.

% Licensed under the Apache License, Version 2.0 (the "License");
% you may not use this file except in compliance with the License.
% You may obtain a copy of the License at

%     http://www.apache.org/licenses/LICENSE-2.0

% Unless required by applicable law or agreed to in writing, software
% distributed under the License is distributed on an "AS IS" BASIS,
% WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
% See the License for the specific language governing permissions and
% limitations under the License.
