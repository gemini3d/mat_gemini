function testok = assert_allclose(actual, desired, rtol, atol, err_msg,warnonly,notclose,verbose)
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
  rtol (1,1) double {mustBePositive} = 1e-8
  atol (1,1) double {mustBeNonnegative} = 1e-9
  err_msg string = string.empty
  warnonly (1,1) logical = false
  notclose (1,1) logical = false
  verbose (1,1) logical = false
end

if warnonly
  efunc = @warning;
else
  efunc = @error;
end

%% compare
actual = actual(:);
desired = desired(:);

if isinteger(desired)
  actual = cast(actual, 'like', desired);
end
measdiff = abs(actual-desired);
tol = atol + rtol * abs(desired);
result = measdiff <= tol;
%% assert_allclose vs assert_not_allclose
if notclose % more than N % of values should be changed more than tolerance (arbitrary)
  testok = sum(~result) > 0.0001*numel(desired);
else
  testok = all(result);
end

if ~testok
  Nfail = sum(~result);
  j = find(~result);
  [bigbad,i] = max(measdiff(j));
  i = j(i);
  if verbose
    disp(['error mag.: ',num2str(measdiff(j)')])
    disp(['tolerance:  ',num2str(tol(j)')])
    disp(['Actual:     ',num2str(actual(i))])
    disp(['desired:    ',num2str(desired(i))])
  end

  emsg = "AssertionError: ";
  if ~isempty(err_msg)
    emsg = emsg + err_msg;
  end
  emsg = emsg + " " + num2str(Nfail/numel(desired)*100,'%.2f') + ...
  "% failed accuracy. maximum error magnitude " + num2str(bigbad) + " Actual: " + ...
  num2str(actual(i)) + " Desired: " + num2str(desired(i)) + " atol: " + num2str(atol) + ...
  " rtol: " + num2str(rtol);

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
