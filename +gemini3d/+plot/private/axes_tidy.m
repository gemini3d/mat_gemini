function axes_tidy(ax, P)
arguments
  ax (1,1)
  P (1,1) struct
end

set(ax, 'ydir', 'normal')

colormap(ax, P.cmap)
if ~isempty(P.caxlims) && all(~isnan(P.caxlims)) && P.caxlims(1) < P.caxlims(2)
  if isMATLABReleaseOlderThan('R2022a')
    caxis(ax, P.caxlims) %#ok<CAXIS>
  else
    clim(ax, P.caxlims)
  end
end

c = colorbar('peer', ax);

if isfield(P, 'parmlbl') && ~isempty(P.parmlbl)
  xlabel(c, P.parmlbl);
end

end % function
