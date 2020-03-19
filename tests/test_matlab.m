% test basic functions

cwd = fileparts(mfilename('fullpath'));
addpath([cwd,'/../matlab'])

%% config.nml load test

p = read_config([cwd, '/config.nml']);

assert(p.xdist == 200000)

%% dateinc test

[ymd, utsec] = dateinc(0.5, [2012,3,27], 1500);
assert(all(ymd == [2012, 3, 27]))
assert(utsec == 1500.5)


% done
disp('OK: gemini-matlab tests')
