function slice3left(ax, x, y, dat, P)

narginchk(5,5)
%% image
hi = imagesc(x, y, dat, 'parent', ax);
set(hi, 'alphadata', ~isnan(dat));
%% line annotation
if ~verLessThan('matlab', '9.5') && ~isempty(P.sourcemlat)
  yline(ax, P.altref, 'Color', 'w', 'LineStyle', '--', 'LineWidth',2)
  xline(ax1, P.sourcemlat, 'k--')
  plot(ax,P.sourcemlat,0,'r^','MarkerSize',12,'LineWidth',2);
end
%% axes
if isfield(P, 'parmlbl')
  P = rmfield(P, 'parmlbl');
end
gemini3d.vis.plotfunctions.axes_tidy(ax, P)

xlabel(ax, P.left_xlabel);
ylabel(ax, P.left_ylabel);

title(ax, [datestr(P.time), ' UT'])

end
