function slice3left(ax, x, y, dat, P)
narginchk(5,5)
%% image
hi = imagesc(x, y, dat, 'parent', ax);
set(hi, 'alphadata', ~isnan(dat));
%% line annotation
if ~verLessThan('matlab', '9.5')
  yline(ax, P.altref, 'Color', 'w', 'LineStyle', '--', 'LineWidth',2)
end
if ~isempty(P.sourcemlat)
  plot(ax,P.sourcemlat,0,'r^','MarkerSize',12,'LineWidth',2);
end
%% axes
axes_tidy(ax, P)

xlabel(ax, 'eastward dist. (km)');
ylabel(ax, 'altitude (km)');

title(ax, [datestr(P.time), ' UT'])

%text(xp(round(lxp/10)),zp(lzp-round(lzp/7.5)),strval,'FontSize',18,'Color',[0.66 0.66 0.66],'FontWeight','bold');
%text(xp(round(lxp/10)),zp(lzp-round(lzp/7.5)),strval,'FontSize',16,'Color',[0.5 0.5 0.5],'FontWeight','bold');

end
