function ok = check_grid(xg)
% sanity check grid

narginchk(1,1)
validateattributes(xg, {'struct'}, {'scalar'}, 1)

tol_inc = 0.1;
tol_inc_big = 1e6;
tol_big = 1e9;

ok = true;
%% check for monotonic increasing and reasonable dimension size
for k = {'x1', 'x1i', 'dx1h', 'x2', 'x2i', 'x3', 'x3i'}
  ok = ok && is_monotonic_increasing(xg.(k{:}), tol_inc, tol_inc_big, k{:});
  ok = ok && not_too_big(xg.(k{:}), tol_big, k{:});
end

%% geo lat/lon

if ~all(xg.glat <= 90 & xg.glat >= -90)
  warning('geo latitude outside expected range')
  ok = false;
end

if ~all(xg.glon >= 0 & xg.glon <= 360)
  warning('geo longitude outside expected range')
  ok = false;
end

end % function


function ok = is_monotonic_increasing(A, tol, big, name)

narginchk(4,4)

dA = diff(A);

ok = all(dA > tol);

if ~ok
  warning('check_grid:is_monotonic_increasing', [name, ' not sufficiently monotonic increasing'])
end

ok_big = all(abs(dA) < big);
if ~ok_big
  warning('check_grid:is_monotonic_increasing', [name, ' has unreasonably large differences'])
end

ok = ok && ok_big;

end % function


function ok = not_too_big(A, tol, name)

narginchk(3,3)

ok = all(abs(A) < tol);

if ~ok
  warning('check_grid:not_too_big', [name, ' is too large to be reasonable.'])
end

end % function