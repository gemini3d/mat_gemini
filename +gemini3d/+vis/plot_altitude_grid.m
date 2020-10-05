function plot_altitude_grid(xg)
%% plot altitude x1 grid
arguments
  xg (1,1) struct
end

x1_km = xg.x1 / 1e3;

fig = figure;
ax = axes('parent', fig);
plot(x1_km, 'marker', '*', 'parent', ax);
ylabel(ax, 'x1 [km]')
xlabel(ax, 'index (dimensionless)')

title(ax, {xg.filename, ...
           "min. alt: " + num2str(min(x1_km), '%0.1f') + " [km] " + ...
           "max. alt: " + num2str(max(x1_km), '%0.1f') + " [km] " + ...
           "lx1=" + int2str(length(x1_km))}, ...
           "interpreter", "none")
end % function
