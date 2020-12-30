function h = grid(xg, extra, save)
%% plot 3D grid
%
% xg: file containing grid or struct of grid

arguments
  xg
  extra (1,:) string = string.empty
  save string = string.empty
end

if ~isstruct(xg)
  xg = gemini3d.read.grid(xg);
end

assert(~isempty(xg), "not contain a readable simulation grid")

h = matlab.ui.Figure.empty;
%% x1, x2, x3
if isempty(extra) || any(extra == "basic")
  h(end+1) = basic(xg);
end
%% detailed altitude plot
if any(extra == "alt")
  h(end+1) = gemini3d.plot.altitude_grid(xg);
end
%% ECEF surface
if any(extra == "ecef")
  fig3 = figure('Name', 'ecef');
  ax = axes('parent', fig3);
  scatter3(xg.x(:), xg.y(:), xg.z(:), 'parent', ax)

  xlabel(ax, 'x [m]')
  ylabel(ax, 'y [m]')
  zlabel(ax, 'z [m]')
  view(ax, 0, 0)
  h(end+1) = stitle(fig3, xg, "ECEF");
end
%% lat lon map
if any(extra == "geog")
  fig = figure('Name', 'geog');
  ax = geoaxes('parent', fig);
  geoscatter(xg.glat(:), xg.glon(:), 'parent', ax)
  h(end+1) = stitle(fig, xg, "glat, glon");
end
%% save
if ~isempty(save)
  for f = h
    filename = f.Name + "." + save;
    exportgraphics(f, filename)
  end
end

if nargout == 0, clear('h'), end
end % function


function fig = basic(xg)
fig = figure('Name', 'basic');
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

fig = stitle(fig, xg);
end


function fig = stitle(fig, xg, ttxt)
arguments
  fig (1,1) matlab.ui.Figure
  xg (1,1) struct
  ttxt (1,1) string = ""
end
%% suptitle
if isfield(xg, 'time')
  ttxt = ttxt + " " + datestr(xg.time) + " ";
  fig.Name = append(fig.Name, int2str(year(xg.time)));
end

if isfield(xg, 'filename')
  ttxt = ttxt + xg.filename;
end

sgtitle(fig, ttxt, 'interpreter', 'none')
end
