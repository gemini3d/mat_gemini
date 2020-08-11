function axes_tidy(ax, P)
narginchk(2,2)

validateattributes(P, {'struct'}, {'scalar'}, 2)

colormap(ax, P.cmap)
caxis(ax, P.caxlims);

c = colorbar(ax);
xlabel(c, P.parmlbl);

end