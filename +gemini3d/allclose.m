function close_enough = allclose(actual, desired, namedargs)
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
% for Matlab and GNU Octave
%
% if "actual" is within atol OR rtol of "desired", return true
arguments
  actual {mustBeNumeric}
  desired {mustBeNumeric}
  namedargs.rtol (1,1) double {mustBePositive} = 1e-8
  namedargs.atol (1,1) double {mustBeNonnegative} = 1e-9
end

%% compare
actual = actual(:);
desired = desired(:);

if isinteger(desired)
  close_enough = isequal(actual, desired);
  return
end

measdiff = abs(actual-desired);
tol = namedargs.atol + namedargs.rtol * abs(desired);

close_enough = all(measdiff <= tol);

end  % function

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
