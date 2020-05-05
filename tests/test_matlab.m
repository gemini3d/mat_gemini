% test basic functions

cwd = fileparts(mfilename('fullpath'));
run([cwd, '/../setup.m'])

%% config.nml load test

p = read_config([cwd, '/test2d_fang/config.nml']);

assert(p.xdist == 200000)

%% dateinc test

[ymd, utsec] = dateinc(0.5, [2012,3,27], 1500);
assert(all(ymd == [2012, 3, 27]))
assert(utsec == 1500.5)

%% test2d_eq
if exist('h5create', 'file')
  model_setup('test2d_eq')
else
  disp('SKIP: missing HDF5')
end

% done
disp('OK: gemini-matlab tests')
