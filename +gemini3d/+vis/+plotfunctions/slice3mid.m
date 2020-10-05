function slice3mid(ax, x, y, dat, P)

%% image
hi = imagesc(x, y, dat, 'parent', ax);
set(hi, 'alphadata', ~isnan(dat));

%% line
hold(ax,'on');
if ~isempty(P.sourcemlat)
  yline(ax, P.sourcemlon, 'Color', 'w', 'LineStyle', '--', 'LineWidth',2);
  plot(ax, P.sourcemlon, P.sourcemlat,'r^','MarkerSize',12,'LineWidth',2);
end
hold(ax,'off');

%% axes
if isfield(P, 'parmlbl')
  P = rmfield(P, 'parmlbl');
end
gemini3d.vis.plotfunctions.axes_tidy(ax, P)

ylabel(ax, P.mid_ylabel)
xlabel(ax, P.mid_xlabel)

end % function
