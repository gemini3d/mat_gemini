function pg = precip_grid(xg, p)
% xg: spatial grid
% p: simulation params
% pg: precipitation params
arguments
  xg (1,1) struct
  p (1,1) struct
end

%% CREATE PRECIPITATION CHARACTERISTICS data
% grid cells will be interpolated to grid, so 100x100 is arbitrary

%% determine what type of grid (cartesian or dipole) we are dealing with
if any(xg.h1 > 1.01)
  flagdip=true;
  disp(' particles_BCs:  Dipole grid detected...');
else
  flagdip=false;
  disp(' particles_BCs:  Cartesian grid detected...');
end %if

pg = struct();

if isfield(p, "precip_llon")
  pg.llon = p.precip_llon;
else
  pg.llon = 100;
end

if isfield(p, "precip_llat")
  pg.llat = p.precip_llat;
else
  pg.llat = 100;
end

if flagdip
  if xg.lx(2) == 1    % dipole
    pg.llat=1;
  elseif xg.lx(3) == 1
    pg.llon=1;
  end
else
  if xg.lx(2) == 1    % cartesian
    pg.llon=1;
  elseif xg.lx(3) == 1
    pg.llat=1;
  end
end %if

%% TIME VARIABLE (seconds FROM SIMULATION BEGINNING)
% dtprec is set in config.nml
pg.times = p.times(1):seconds(p.dtprec):p.times(end);
Nt = length(pg.times);

%% CREATE PRECIPITATION INPUT DATA
% Qit: energy flux [mW m^-2]
% E0it: characteristic energy [eV]
% NOTE: since Fortran Gemini interpolates between time steps,
% having E0 default to zero is NOT appropriate, as the file before and/or
% after precipitation would interpolate from E0=0 to desired value, which
% is decidely non-physical.
% We default E0 to NaN so that it's obvious (by Gemini emitting an
% error) that an unexpected input has occurred.
pg.Qit = zeros(pg.llon, pg.llat, Nt);
pg.E0it = nan(pg.llon, pg.llat, Nt);

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
