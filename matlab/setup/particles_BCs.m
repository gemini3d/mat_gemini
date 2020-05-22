function particles_BCs(p, xg)
% create particle precipitation
narginchk(2,2)
validateattributes(p, {'struct'}, {'scalar'})
validateattributes(xg, {'struct'}, {'scalar'})
%% CREATE PRECIPITATION CHARACTERISTICS data
% number of grid cells.
% This will be interpolated to grid, so 100x100 is arbitrary
pg.llon=100;
pg.llat=100;

if xg.lx(2) == 1    % cartesian
  pg.llon=1;
elseif xg.lx(3) == 1
  pg.llat=1;
end

%% TIME VARIABLE (SECONDS FROM SIMULATION BEGINNING)
% dtprec is set in config.nml
time = 0:p.dtprec:p.tdur;
Nt = numel(time);

%% time
UTsec = p.UTsec0 + time;     % seconds from beginning of hour
UThrs = UTsec/3600;
pg.expdate=cat(2,repmat(p.ymd(:)',[Nt,1]),UThrs(:),zeros(Nt,1),zeros(Nt,1));

%% CREATE PRECIPITATION INPUT DATA
% Qit: energy flux [mW m^-2]
% E0it: characteristic energy [eV]
pg.Qit = zeros(pg.llon, pg.llat, Nt);
pg.E0it = zeros(pg.llon,pg.llat, Nt);

% did user specify on/off time? if not, assume always on.
if isfield(p, 'precip_startsec')
  [~, i_on] = min(abs(time - p.precip_startsec));
else
  i_on = 1;
end

if isfield(p, 'precip_endsec')
  [~, i_off] = min(abs(time - p.precip_endsec));
else
  i_off = Nt;
end

pg = precip_grid(xg, p, pg);

% NOTE: in future, E0 could be made time-dependent in config.nml as 1D array
for i = i_on:i_off
   pg.Qit(:,:,i) = precip_gaussian2d(pg, p.Qprecip, p.Qprecip_background);
   p.gE0it(:,:,i) = p.E0precip;
end

if any(~isfinite(pg.Qit)), error('particle_BCs:value_error', 'precipitation flux not finite'), end
if any(~isfinite(pg.E0it)), error('particle_BCs:value_error', 'E0 not finite'), end

%% CONVERT THE ENERGY TO EV
%E0it = max(E0it,0.100);
%E0it = E0it*1e3;

if strcmp(p.file_format, 'raw')
  write_precip(pg, p.prec_dir, p.realbits)
else
  write_precip(pg, p.prec_dir, p.file_format)
end

end % function
