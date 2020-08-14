function particles_BCs(p, xg)
% create particle precipitation
import gemini3d.fileio.*

narginchk(2,2)
validateattributes(p, {'struct'}, {'scalar'})
validateattributes(xg, {'struct'}, {'scalar'})

outdir = p.prec_dir;
makedir(outdir)

%% CREATE PRECIPITATION CHARACTERISTICS data
% number of grid cells.
% This will be interpolated to grid, so 100x100 is arbitrary
precip = struct('llon', 100, 'llat', 100);

if xg.lx(2) == 1    % cartesian
  precip.llon=1;
elseif xg.lx(3) == 1
  precip.llat=1;
end

%% TIME VARIABLE (seconds FROM SIMULATION BEGINNING)
% dtprec is set in config.nml
precip.times = p.times(1):seconds(p.dtprec):p.times(end);
Nt = length(precip.times);

%% CREATE PRECIPITATION INPUT DATA
% Qit: energy flux [mW m^-2]
% E0it: characteristic energy [eV]
precip.Qit = zeros(precip.llon, precip.llat, Nt);
precip.E0it = zeros(precip.llon,precip.llat, Nt);

% did user specify on/off time? if not, assume always on.
if isfield(p, 'precip_startsec')
  i_on = round(p.precip_startsec / p.dtprec);
else
  i_on = 1;
end

if isfield(p, 'precip_endsec')
  i_off = round(p.precip_endsec / p.dtprec);
else
  i_off = Nt;
end

if ~isfield(p, 'Qprecip')
  warning('You should specify "Qprecip, Qprecip_background, E0precip" in "setup" namelist of config.nml. Defaulting to Q=1, E0=1000')
  Qprecip = 1;
  Qprecip_bg = 0.01;
  E0precip = 1000;
else
  Qprecip = p.Qprecip;
  Qprecip_bg = p.Qprecip_background;
  E0precip = p.E0precip;
end

precip = gemini3d.setup.precip_grid(xg, p, precip);

% NOTE: in future, E0 could be made time-dependent in config.nml as 1D array
for i = i_on:i_off
   precip.Qit(:,:,i) = gemini3d.setup.precip_gaussian2d(precip, Qprecip, Qprecip_bg);
   precip.E0it(:,:,i) = E0precip;
end

if any(~isfinite(precip.Qit)), error('particle_BCs:value_error', 'precipitation flux not finite'), end
if any(~isfinite(precip.E0it)), error('particle_BCs:value_error', 'E0 not finite'), end

%% CONVERT THE ENERGY TO EV
%E0it = max(E0it,0.100);
%E0it = E0it*1e3;

gemini3d.setup.write_precip(precip, outdir, p.file_format)

end % function
