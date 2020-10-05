function plot_grid(path)
%% plot 3D grid
%
% path: path to simgrid.{dat,h5,nc}

arguments
  path (1,1) string
end

xg = gemini3d.readgrid(path);

fig = figure();
t = tiledlayout(fig, 1, 3);

%% x1
lx1 = length(xg.x1);
ax = nexttile(t);
plot(ax, 1:lx1, xg.x1/1e3, 'marker', '.')
ylabel(ax, 'x1 [km]')
xlabel(ax, 'index (dimensionless)')
title(ax, {"x1 (upward)", "lx1 = " + int2str(lx1)})

%% x2
lx2 = length(xg.x2);
ax = nexttile(t);
plot(ax, xg.x2/1e3, 1:lx2, 'marker', '.')
xlabel(ax, 'x2 [km]')
ylabel(ax, 'index (dimensionless)')
title(ax, {"x2 (eastward)", "lx2 = " + int2str(lx2)})

%% x3
lx3 = length(xg.x3);
ax = nexttile(t);
plot(ax, 1:lx3, xg.x3/1e3, 'marker', '.')
ylabel(ax, 'x3 [km]')
xlabel(ax, 'index (dimensionless)')
title(ax, {"x3 (northward)", "lx3 = " + int2str(lx3)})

sgtitle(fig, path, 'interpreter', 'none')
%% duplicate but detailed altitude plot
gemini3d.vis.plot_altitude_grid(xg)

end % function
