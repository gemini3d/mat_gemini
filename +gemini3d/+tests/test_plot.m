% setup
d2 = "+gemini3d/+tests/data/test2dew_glow";
d3 = "+gemini3d/+tests/data/test3d_glow";
%% plotframe simple
% this is used internally and also directly by external scripts
h = gemini3d.vis.plotframe(d2, datetime(2013, 2, 20, 5, 5, 0));
close(h)
%% plotframe advanced
h = gemini3d.vis.plotinit(gemini3d.readgrid(d2));
gemini3d.vis.plotframe(d2, datetime(2013, 2, 20, 5, 5, 0), "figures", h)
close(h)
%% plot 2d
h = gemini3d.gemini_plot(d2);
close(h)
%% plot 3d
h = gemini3d.gemini_plot(d3);
close(h)
