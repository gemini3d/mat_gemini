function plot_phitop(x, y, Phitop, h, P)
% phi_top is Topside Potential
arguments
  x (:,1) {mustBeNumeric,mustBeFinite}
  y (:,1) {mustBeNumeric,mustBeFinite}
  Phitop (:,:) {mustBeNumeric,mustBeNonempty}
  h (1,1)
  P (1,1) struct
end

ax = gemini3d.vis.plotfunctions.get_axes(h);
hi = imagesc(x, y, Phitop, 'parent', ax);
set(hi, 'alphadata', ~isnan(Phitop))

gemini3d.vis.plotfunctions.axes_tidy(ax, P)

ylabel(ax, 'northward dist. (km)')
xlabel(ax, 'eastward dist. (km)')

title(ax, datestr(P.time) + " UT")

end
