function slice3left(ax, x, y, dat, P)

%% image
hi = imagesc(x, y, dat, 'parent', ax);
set(hi, 'alphadata', ~isnan(dat));
%% line annotation
hold(ax,'on');
if ~isempty(P.sourcemlat)
  yline(ax, P.altref, 'Color', 'w', 'LineStyle', '--', 'LineWidth',2)
  xline(ax, P.sourcemlat, 'k--')
  plot(ax,P.sourcemlat,0,'r^','MarkerSize',12,'LineWidth',2);
end
hold(ax,'off');

%% axes
if isfield(P, 'parmlbl')
  P = rmfield(P, 'parmlbl');
end
axes_tidy(ax, P)

xlabel(ax, P.left_xlabel);
ylabel(ax, P.left_ylabel);

title(ax, string(P.time) + " UT")

end % function
