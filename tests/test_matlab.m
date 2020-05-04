% test basic functions

cwd = fileparts(mfilename('fullpath'));
addpath([cwd,'/../matlab'])

%% config.nml load test

p = read_config([cwd, '/test2d_fang/config.nml']);

assert(p.xdist == 200000)

%% dateinc test

[ymd, utsec] = dateinc(0.5, [2012,3,27], 1500);
assert(all(ymd == [2012, 3, 27]))
assert(utsec == 1500.5)

%% test2d_eq
model_setup('test2d_eq')

%% test2d_fang
model_setup('test2d_fang')

% done
disp('OK: gemini-matlab tests')
