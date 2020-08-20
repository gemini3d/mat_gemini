function axes_tidy(ax, P)
narginchk(2,2)

validateattributes(P, {'struct'}, {'scalar'}, 2)

set(ax, 'ydir', 'normal')

colormap(ax, P.cmap)
if ~isempty(P.caxlims) && all(~isnan(P.caxlims)) && P.caxlims(1) < P.caxlims(2)
  caxis(ax, P.caxlims);
end

c = colorbar('peer', ax);

if isfield(P, 'parmlbl') && ~isempty(P.parmlbl)
  xlabel(c, P.parmlbl);
end

end % function