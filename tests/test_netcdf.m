% test our custom high-level NetCDF4 interface
cwd = fileparts(mfilename('fullpath'));
run(fullfile(cwd, '../setup.m'))

A0 = 42.;
A1 = [42., 43.];
A2 = magic(4);
A3 = A2(:,1:3,1);
A3(:,:,2) = 2*A3;
A4(:,:,:,5) = A3;

if isoctave
  pkg('load','netcdf')
end
%% test_write_basic
f1 = fullfile(tempdir, '1.nc');
ncsave(f1, 'A0', A0)
ncsave(f1, 'A1', A1)
ncsave(f1, 'A2', A2, {'x2', size(A2,1), 'y2', size(A2,2)})
ncsave(f1, 'A3', A3, {'x3', size(A3,1), 'y3', size(A3,2), 'z3', size(A3,3)})
ncsave(f1, 'A4', A4, {'x4', size(A4,1), 'y4', size(A4,2), 'z4', size(A4,3), 'w4', size(A4,4)})

vars = ncvariables(f1);
assert(isequal(sort(vars),{'A0', 'A1', 'A2', 'A3', 'A4'}), 'missing variables')

assert(ncexists(f1, 'A3'), 'A3 exists')
assert(~ncexists(f1, 'oops'), 'oops not exist')

s = ncsize(f1, 'A0');
assert(isscalar(s) && s==1, 'A0 shape')

s = ncsize(f1, 'A1');
assert(isscalar(s) && s==2, 'A1 shape')

s = ncsize(f1, 'A2');
assert(isvector(s) && isequal(s, [4,4]), 'A2 shape')

s = ncsize(f1, 'A3');
assert(isvector(s) && isequal(s, [4,3,2]), 'A3 shape')

s = ncsize(f1, 'A4');
assert(isvector(s) && isequal(s, [4,3,2,5]), 'A4 shape')

ncsave(f1, 'A2', 3*magic(4))
assert(isequal(ncread(f1, 'A2'), 3*magic(4)), 'rewrite 2D fail')
%% test_coerce
f2 = fullfile(tempdir, '2.nc');
ncsave(f2, 'int32', A0, [], 'int32')
ncsave(f2, 'int64', A0, [], 'int64')
ncsave(f2, 'float32', A0, [], 'float32')

assert(isa(ncread(f2, 'int32'), 'int32'), 'int32')
assert(isa(ncread(f2, 'int64'), 'int64'), 'int64')
assert(isa(ncread(f2, 'float32'), 'single'), 'float32')
