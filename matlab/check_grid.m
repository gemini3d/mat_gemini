function ok = check_grid(xg)
% sanity check grid

narginchk(1,1)
validateattributes(xg, {'struct'}, {'scalar'}, 1)

tol_inc = 0.1;

ok = true;
%% check for monotonic increasing
ok = ok && is_monotonic_increasing(xg.x1, tol_inc, 'x1');
ok = ok && is_monotonic_increasing(xg.x2, tol_inc, 'x2');
ok = ok && is_monotonic_increasing(xg.x3, tol_inc, 'x3');
end


function ok = is_monotonic_increasing(A, tol, name)

validateattributes(A, {'numeric'}, {'vector'})
validateattributes(tol, {'numeric'}, {'scalar'})

ok = all(diff(A) > tol);

if ~ok
  warning('check_grid:is_monotonic_increasing', [name, ' not sufficiently monotonic increasing'])
end

end % function