% test project generation

cwd = fileparts(mfilename('fullpath'));
addpath(cwd) % since we have to cd() in runner()

run(fullfile(cwd, '../setup.m'))

if isoctave
  pkg('load','netcdf')
end

tic
%% test2dew_eq_nc
runner('2dew_eq', 'nc')
%% test2dew_fang_nc
runner('2dew_fang', 'nc')
%% test2dew_glow_nc
runner('2dew_glow', 'nc')
%% test2dns_eq_nc
runner('2dns_eq', 'nc')
%% test2dns_fang_nc
runner('2dns_fang', 'nc')
%% test2dns_glow_nc
runner('2dns_glow', 'nc')
%% test3d_eq_nc
runner('3d_eq', 'nc')
%% test3d_fang_nc
runner('3d_fang', 'nc')
%% test3d_glow_nc
runner('3d_glow', 'nc')

toc
