function slice3right(ax, x, y, dat, P)

%% image
hi = imagesc(ax, x, y, dat);
set(hi, 'alphadata', ~isnan(dat));
%% line
if ~verLessThan('matlab', '9.5')
  % yline(ha, P.altref, 'w--','LineWidth',2);
end
if ~isempty(P.sourcemlat)
  plot(ax, P.sourcemlat,0,'r^','MarkerSize',12,'LineWidth',2);
end
%% axes
gemini3d.vis.plotfunctions.axes_tidy(ax, P)

xlabel(ax, P.right_xlabel)
ylabel(ax, P.right_ylabel)

end % function
