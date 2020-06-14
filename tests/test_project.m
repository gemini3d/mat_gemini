% test basic functions

cwd = fileparts(mfilename('fullpath'));
addpath(cwd) % since we have to cd() in runner()

run(fullfile(cwd, '../setup.m'))

tic
%% test2dew_eq_h5
runner('2d_eq', 'h5')
%% test2dew_fang_h5
runner('2d_fang', 'h5')
%% test2dew_glow_h5
runner('2d_glow', 'h5')
%% test3d_eq_h5
runner('3d_eq', 'h5')
%% test3d_fang_h5
runner('3d_fang', 'h5')
%% test3d_glow_h5
runner('3d_glow', 'h5')

%% test2dew_eq_nc
runner('2d_eq', 'nc')
%% test2dew_fang_nc
runner('2d_fang', 'nc')
%% test2dew_glow_nc
runner('2d_glow', 'nc')
%% test3d_eq_nc
runner('3d_eq', 'nc')
%% test3d_fang_nc
runner('3d_fang', 'nc')
%% test3d_glow_nc
runner('3d_glow', 'nc')
toc
