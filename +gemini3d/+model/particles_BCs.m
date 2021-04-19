function particles_BCs(p, xg)
% create particle precipitation
arguments
  p (1,1) struct
  xg (1,1) struct
end

precip = gemini3d.setup.precip_grid(xg, p);

Nt = length(precip.times);

% did user specify on/off time? if not, assume always on.
% because of one-based Matlab indexing, i_on and i_off have a "+1"
if isfield(p, 'precip_startsec')
  i_on = round(p.precip_startsec / p.dtprec) + 1;
else
  i_on = 1;
end

if isfield(p, 'precip_endsec')
  i_off = round(min(p.tdur, p.precip_endsec) / p.dtprec) + 1;
else
  i_off = Nt;  % not +1
end

mustBeFinite(p.E0precip)
mustBePositive(p.E0precip)
mustBeLessThan(p.E0precip, 100e6)
% ionization model vis relativistic particles 100MeV

% NOTE: in future, E0 could be made time-dependent in config.nml as 1D array

if isfield(p, "Qprecip_function")
  Qfunc = str2func(p.Qprecip_function);
else
  Qfunc = str2func("gemini3d.setup.precip_gaussian2d");
end

for i = i_on:i_off
  precip.Qit(:,:,i) = Qfunc(precip, p.Qprecip, p.Qprecip_background);
  precip.E0it(:,:,i) = p.E0precip;
end

mustBeFinite(precip.Qit)
mustBeNonnegative(precip.Qit)

%% CONVERT THE ENERGY TO EV
%E0it = max(E0it,0.100);
%E0it = E0it*1e3;

gemini3d.write.precip(precip, p.prec_dir, p.file_format)

end % function
