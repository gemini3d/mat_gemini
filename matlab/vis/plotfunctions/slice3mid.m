function slice3mid(ax, x, y, dat, P)
narginchk(5,5)

%% image
hi = imagesc(x, y, dat, 'parent', ax);
set(hi, 'alphadata', ~isnan(dat));

%% line
if ~isempty(P.sourcemlat)
  if ~verLessThan('matlab', '9.5')
    yline(ax, P.sourcemlon, 'Color', 'w', 'LineStyle', '--', 'LineWidth',2);
  end
  plot(ax, P.sourcemlat, P.sourcemlon,'r^','MarkerSize',12,'LineWidth',2);
end

%% axes
axes_tidy(ax, P)

ylabel(ax, 'northward dist. (km)');
xlabel(ax, 'eastward dist. (km)');

end
