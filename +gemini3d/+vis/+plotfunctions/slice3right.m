function slice3right(ax, x, y, dat, P)

%% image
hi = imagesc(ax, x, y, dat);
set(hi, 'alphadata', ~isnan(dat));
%% line
hold(ax,'on');
if ~verLessThan('matlab', '9.5')
   yline(ax, P.altref, 'w--','LineWidth',2);
end
if ~isempty(P.sourcemlon)
  plot(ax, P.sourcemlon,0,'r^','MarkerSize',12,'LineWidth',2);
end
hold(ax,'off');

%% axes
gemini3d.vis.plotfunctions.axes_tidy(ax, P)

xlabel(ax, P.right_xlabel)
ylabel(ax, P.right_ylabel)

end % function
