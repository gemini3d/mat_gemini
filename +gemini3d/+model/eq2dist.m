function ic_interp = eq2dist(p, xg)
% read and interpolate equilibrium simulation data, writing new
% interpolated grid.
arguments
  p (1,1) struct
  xg (1,1) struct
end

gemini3d.sys.check_stdlib()

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
dat = gemini3d.read.frame(p.eq_dir, time=peq.times(end), cfg=peq);

%% sanity check equilibrium simulation input to interpolation
check_density(dat.ns)
check_drift(dat.vs1)
check_temperature(dat.Ts)

%% DO THE INTERPOLATION
ic_interp = gemini3d.model.resample(xgin, dat, xg);
ic_interp.time=peq.times(end);

%% sanity check interpolated variables
check_density(ic_interp.ns)
check_drift(ic_interp.vs1)
check_temperature(ic_interp.Ts)

%% write the interpolated grid and data
gemini3d.write.grid(p, xg)
gemini3d.write.state(p.indat_file, ic_interp);

end % function eq2dist


function peq = read_equilibrium(p)

assert(isfield(p, "eq_dir"), "equilibrium directory eq_dir must be specified in struct p input to eq2dist")

if isfolder(p.eq_dir)
  peq = gemini3d.read.config(p.eq_dir);
  return
end

if ~all(isfield(p, ["eq_url", "eq_archive"]))
  if isfield(p, "nml")
    n = p.nml;
  else
    n = "config.nml";
  end
  error("gemini3d:model:eq2dist", "run equilibrium simulation in %s \n OR specify eq_url and eq_archive in %s", p.eq_dir, n)
end

if ~isfile(p.eq_archive)
  download_equilibrium(p.eq_url, p.eq_archive, isfield(p, 'ssl_verify') && p.ssl_verify)
end

gemini3d.fileio.extract_data(p.eq_archive, p.eq_dir)

peq = gemini3d.read.config(p.eq_dir);

end
