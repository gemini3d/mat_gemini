function h = plot_grid(path)
%% plot 3D grid
%
% path: path to simgrid.{dat,h5,nc}

arguments
  path (1,1) string
end

xg = gemini3d.readgrid(path);

assert(~isempty(xg), path + " does not contain a readable simulation grid e.g. inputs/simgrid.h5")

fig1 = figure();
t = tiledlayout(fig1, 1, 3);

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

sgtitle(fig1, path, 'interpreter', 'none')
%% duplicate but detailed altitude plot
fig2 = gemini3d.vis.plot_altitude_grid(xg);

h = [fig1, fig2];

if nargout == 0, clear('h'), end
end % function
