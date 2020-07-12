% test our custom high-level HDF5 interface
cwd = fileparts(mfilename('fullpath'));
run(fullfile(cwd, '../setup.m'))

A0 = 42.;
A1 = [42., 43.];
A2 = magic(4);
A3 = A2(:,1:3,1);
A3(:,:,2) = 2*A3;
A4(:,:,:,5) = A3;

%% test_write_basic
f1 = fullfile(tempdir, '1.h5');
h5save(f1, '/A0', A0)
h5save(f1, '/A1', A1)
h5save(f1, '/A2', A2)
h5save(f1, '/A3', A3)
h5save(f1, '/A4', A4)

vars = h5variables(f1);
assert(isequal(sort(vars),{'A0', 'A1', 'A2', 'A3', 'A4'}), 'missing variables')

assert(h5exists(f1, '/A3'), 'A3 exists')
assert(~h5exists(f1, '/oops'), 'oops not exist')

s = h5size(f1, '/A0');
assert(isscalar(s) && s==1, 'A0 shape')

s = h5size(f1, '/A1');
assert(isscalar(s) && s==2, 'A1 shape')

s = h5size(f1, '/A2');
assert(isvector(s) && isequal(s, [4,4]), 'A2 shape')

s = h5size(f1, '/A3');
assert(isvector(s) && isequal(s, [4,3,2]), 'A3 shape')

s = h5size(f1, '/A4');
assert(isvector(s) && isequal(s, [4,3,2,5]), 'A4 shape')

h5save(f1, '/A2', 3*magic(4))
assert(isequal(h5read(f1, '/A2'), 3*magic(4)), 'rewrite 2D fail')
%% test_coerce
f2 = fullfile(tempdir, '2.h5');
h5save(f2, '/int32', A0, [], 'int32')
h5save(f2, '/int64', A0, [], 'int64')
h5save(f2, '/float32', A0, [], 'float32')

assert(isa(h5read(f2, '/int32'), 'int32'), 'int32')
assert(isa(h5read(f2, '/int64'), 'int64'), 'int64')
assert(isa(h5read(f2, '/float32'), 'single'), 'float32')
