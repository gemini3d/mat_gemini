function pg = precip_grid(xg, p, pg)
% xg: spatial grid
% p: simulation params
% pg: precipitation params
arguments
  xg (1,1) struct
  p (1,1) struct
  pg (1,1) struct
end

thetamin = min(xg.theta(:));
thetamax = max(xg.theta(:));
mlatmin = 90-thetamax*180/pi;
mlatmax = 90-thetamin*180/pi;
mlonmin = min(xg.phi(:))*180/pi;
mlonmax = max(xg.phi(:))*180/pi;

% add a 1% buffer
latbuf = 1/100*(mlatmax-mlatmin);
lonbuf = 1/100*(mlonmax-mlonmin);
% create the lat,lon grid
pg.mlat = linspace(mlatmin-latbuf,mlatmax+latbuf, pg.llat);
pg.mlon = linspace(mlonmin-lonbuf,mlonmax+lonbuf, pg.llon);
[pg.MLON, pg.MLAT] = ndgrid(pg.mlon, pg.mlat);
pg.mlon_mean = mean(pg.mlon);
pg.mlat_mean = mean(pg.mlat);

%% disturbance extents
% avoid divide by zero
if isfield(p, 'precip_latwidth')
  pg.mlat_sigma = max(p.precip_latwidth*(mlatmax-mlatmin), 0.01);
end
if isfield(p, 'precip_lonwidth')
  pg.mlon_sigma = max(p.precip_lonwidth*(mlonmax-mlonmin), 0.01);
end

end % function
