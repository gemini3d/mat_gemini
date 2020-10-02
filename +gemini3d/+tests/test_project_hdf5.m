% test project generation
% plots have to be tested here to avoid needing other test state
import gemini3d.tests.runner

cwd = fileparts(mfilename("fullpath"));

%% test2dew_eq_h5
runner('2dew_eq', 'h5')
%% test2dew_fang_h5
runner('2dew_fang', 'h5')
%% test2dew_glow_h5
runner('2dew_glow', 'h5')
% test 2D plots
h = gemini3d.vis.plotframe(fullfile(cwd, "data/test2dew_glow"), datetime(2013, 2, 20, 5, 5, 0));
close(h)
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
% test 3D plots
d3 = fullfile(cwd, "data/test3d_glow");
h = gemini3d.vis.plotinit(gemini3d.readgrid(d3));
gemini3d.vis.plotframe(d3, datetime(2013, 2, 20, 5, 5, 0), "figures", h)
close(h)
