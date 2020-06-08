function ok = check_grid(xg)
% sanity check grid

narginchk(1,1)
validateattributes(xg, {'struct'}, {'scalar'}, 1)

tol_inc = 0.1;

ok = true;
%% check for monotonic increasing
for k = {'x1', 'x1i', 'dx1h', 'x2', 'x2i', 'x3', 'x3i'}
  ok = ok && is_monotonic_increasing(xg.(k{:}), tol_inc, k{:});
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


function ok = is_monotonic_increasing(A, tol, name)

narginchk(3,3)
validateattributes(A, {'numeric'}, {'vector'}, 1)
validateattributes(tol, {'numeric'}, {'scalar'}, 2)
validateattributes(name, {'char'}, {'vector'}, 3)

ok = all(diff(A) > tol);

if ~ok
  warning('check_grid:is_monotonic_increasing', [name, ' not sufficiently monotonic increasing'])
end

end % function