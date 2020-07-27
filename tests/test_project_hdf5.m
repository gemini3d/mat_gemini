% test project generation

cwd = fileparts(mfilename('fullpath'));
addpath(cwd) % since we have to cd() in runner()

run(fullfile(cwd, '../setup.m'))

tic
%% test2dew_eq_h5
runner('2dew_eq', 'h5')
%% test2dew_fang_h5
runner('2dew_fang', 'h5')
%% test2dew_glow_h5
runner('2dew_glow', 'h5')
%% test2dns_eq_h5
runner('2dns_eq', 'h5')
%% test2dns_fang_h5
runner('2dns_fang', 'h5')
%% test2dns_glow_h5
runner('2dns_glow', 'h5')
%% test3d_eq_h5
runner('3d_eq', 'h5')
%% test3d_fang_h5
runner('3d_fang', 'h5')
%% test3d_glow_h5
runner('3d_glow', 'h5')

toc
