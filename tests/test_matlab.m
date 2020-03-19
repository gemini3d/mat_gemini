% test basic functions

cwd = fileparts(mfilename('fullpath'));
addpath([cwd,'/../matlab'])

%% config.nml load test

p = read_config([cwd, '/config.nml']);

assert(p.xdist == 200000)
