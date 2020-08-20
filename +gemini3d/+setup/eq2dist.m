function [nsi,vs1i,Tsi] = eq2dist(p, xg)
% read and interpolate equilibrium simulation data, writing new
% interpolated grid.

narginchk(2, 2)
validateattributes(p, {'struct'}, {'scalar'}, mfilename, 'parameters', 1)
validateattributes(xg, {'struct'}, {'scalar'}, mfilename, 'grid struct', 2)

%% READ Equilibrium SIMULATION INFO
if ~isfolder(p.eq_dir)
  if isfield(p, 'eq_url')
    if ~isfile(p.eq_zip)
        if isfield(p, 'ssl_verify') && ~p.ssl_verify
          % disable SSL, better to fix your SSL certificates as arbitrary
          % code can be downloaded
          web_opt = weboptions('CertificateFilename', '');
        else
          web_opt = weboptions('CertificateFilename', 'default');
        end
      gemini3d.fileio.makedir(p.eq_dir)
      websave(p.eq_zip, p.eq_url, web_opt);
    end
    unzip(p.eq_zip, fullfile(p.eq_dir, '..'))
  else
    error('eq2dist:file_not_found', '%s not found--was the equilibrium simulation run first?  Or specify eq_url and eq_zip to download.', p.eq_dir)
  end
end

peq = gemini3d.read_config(p.eq_dir);
%% read equilibrium grid
[xgin, ok] = gemini3d.readgrid(p.eq_dir);

if ~ok
  error('eq2dist:value_error', 'problem with equilibrium input grid %s', p.eq_dir)
end

%% END FRAME time of equilibrium simulation
% PRESUMABLY THIS WILL BE THE STARTING point FOR another
%% LOAD THE last equilibrium frame
dat = gemini3d.vis.loadframe(p.eq_dir, peq.times(end), xgin);

%% sanity check equilibrium simulation input to interpolation
check_density(dat.ns)
check_drift(dat.vs1)
check_temperature(dat.Ts)

%% DO THE INTERPOLATION
[nsi,vs1i,Tsi] = gemini3d.setup.model_resample(xgin, dat.ns, dat.vs1, dat.Ts, xg);

%% sanity check interpolated variables
check_density(nsi)
check_drift(vs1i)
check_temperature(Tsi)

%% write the interpolated grid and data
gemini3d.writegrid(p, xg)
gemini3d.writedata(peq.times(end), nsi, vs1i, Tsi, p.indat_file, p.file_format);

end % function eq2dist


function check_density(n)
narginchk(1,1)

n = n(:);
assert(all(isfinite(n)), 'non-finite density')
assert(all(n > 0), 'negative density')
assert(max(n > 1e6), 'too small maximum density')
end

function check_drift(v)
narginchk(1,1)

v = v(:);
assert(all(isfinite(v)), 'non-finite drift')
assert(all(abs(v) < 10e3), 'excessive drift velocity')
end

function check_temperature(T)

T = T(:);
assert(all(isfinite(T)), 'non-finite temperature')
assert(all(T > 0), 'negative temperature')
assert(max(T) > 500, 'too cold maximum temperature')

end
