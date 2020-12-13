function [nsi,vs1i,Tsi] = eq2dist(p, xg)
% read and interpolate equilibrium simulation data, writing new
% interpolated grid.
arguments
  p (1,1) struct
  xg (1,1) struct
end

peq = read_equilibrium(p);
%% read equilibrium grid
[xgin, ok] = gemini3d.read.grid(p.eq_dir);

if ~ok
  error('eq2dist:value_error', 'problem with equilibrium input grid %s', p.eq_dir)
end

%% END FRAME time of equilibrium simulation
% PRESUMABLY THIS WILL BE THE STARTING point FOR another
%% LOAD THE last equilibrium frame
% we need to pass in peq so that flagoutput works for .dat files, particularly for big old simulations
% we don't want to spend time rerunning.
dat = gemini3d.read.frame(p.eq_dir, "time", peq.times(end), "cfg", peq);

%% sanity check equilibrium simulation input to interpolation
check_density(dat.ns)
check_drift(dat.vs1)
check_temperature(dat.Ts)

%% DO THE INTERPOLATION
[nsi,vs1i,Tsi] = gemini3d.model.resample(xgin, dat.ns, dat.vs1, dat.Ts, xg);

%% sanity check interpolated variables
check_density(nsi)
check_drift(vs1i)
check_temperature(Tsi)

%% write the interpolated grid and data
gemini3d.write.grid(p, xg)
gemini3d.write.data(peq.times(end), nsi, vs1i, Tsi, p.indat_file, p.file_format);

end % function eq2dist


function peq = read_equilibrium(p)

if ~isfolder(p.eq_dir)
  if isfield(p, 'eq_url')
    if ~isfile(p.eq_zip)
      if isfield(p, 'ssl_verify') && ~p.ssl_verify
        % disable SSL, better to fix your SSL certificates as arbitrary
        % code can be downloaded
        web_opt = weboptions('CertificateFilename', '');
      elseif isfile(getenv("SSL_CERT_FILE"))
        web_opt = weboptions('CertificateFilename', getenv("SSL_CERT_FILE"));
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

peq = gemini3d.read.config(p.eq_dir);

end
