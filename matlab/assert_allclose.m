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

narginchk(2,8)
validateattributes(actual, {'numeric'}, {'nonempty'}, mfilename, 'measured values', 1)
validateattributes(desired, {'numeric'}, {'nonempty'}, mfilename, 'desired reference values', 2)
if nargin < 3 || isempty(rtol)
  rtol=1e-8;
else
  validateattributes(rtol, {'numeric'}, {'scalar', 'nonnegative'}, mfilename, 'relative tolerance', 3)
end
if nargin < 4 || isempty(atol)
  atol = 1e-9;
else
  validateattributes(atol, {'numeric'}, {'scalar', 'nonnegative'}, mfilename, 'absolute tolerance', 4)
end
if nargin < 5
  err_msg='';
else
  validateattributes(err_msg, {'char'}, {'vector'}, mfilename, 'error message text', 5)
end
if nargin < 6
  warnonly=false;
else
  validateattributes(warnonly, {'logical'}, {'scalar'}, mfilename, 'warn instead of error', 6)
end
if nargin < 7
  notclose=false;
else
  validateattributes(notclose, {'logical'}, {'scalar'}, mfilename, 'check values not too close', 7)
end
if nargin < 8
  verbose = false;
else
  validateattributes(verbose, {'logical'}, {'scalar'}, mfilename, 'verbose output', 8)
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

  efunc(['AssertionError: ',err_msg,' ',num2str(Nfail/numel(desired)*100,'%.2f'),'% failed accuracy. maximum error magnitude ',num2str(bigbad),' Actual: ',num2str(actual(i)),' Desired: ',num2str(desired(i)),' atol: ',num2str(atol),' rtol: ',num2str(rtol)])
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
