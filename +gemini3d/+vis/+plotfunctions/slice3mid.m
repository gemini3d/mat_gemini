function slice3mid(ax, x, y, dat, P)

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
if isfield(P, 'parmlbl')
  P = rmfield(P, 'parmlbl');
end
gemini3d.vis.plotfunctions.axes_tidy(ax, P)

ylabel(ax, P.mid_ylabel)
xlabel(ax, P.mid_xlabel)

end % function
