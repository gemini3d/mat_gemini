function axes_tidy(ax, P)
narginchk(2,2)

validateattributes(P, {'struct'}, {'scalar'}, 2)

set(ax, 'ydir', 'normal')

colormap(ax, P.cmap)
if ~isempty(P.caxlims) && all(~isnan(P.caxlims)) && P.caxlims(1) < P.caxlims(2)
  caxis(ax, P.caxlims);
end

c = colorbar('peer', ax);

xlabel(c, P.parmlbl);

end