function [cfg, xg] = model_setup(cfg, outdir)
%% determines what kind of setup is needed and does it.
arguments
  cfg = pwd
  outdir string = string.empty
end

%% parse input
if isstruct(cfg)
  % pass
elseif isstring(cfg) || ischar(cfg)
  % path to config.nml
  cfg = gemini3d.read_config(cfg);
else
  error('model_setup:value_error', 'need path to config.nml')
end

if isempty(outdir)
  if ~isfield(cfg, 'outdir') || isempty(cfg.outdir)
    error('model_setup:file_not_found', 'please specify outdir or p.outdir')
  end
else
  % override with outdir regardless
  cfg.outdir = outdir;
end

cfg = gemini3d.make_valid_paths(cfg);

gemini3d.fileio.makedir(cfg.input_dir)
fprintf('copying config.nml to %s\n', cfg.input_dir);
gemini3d.fileio.copy_file(cfg.nml, cfg.input_dir)


%% is this equilibrium or interpolated simulation
if isfield(cfg, 'eq_dir') && ~isempty(cfg.eq_dir)
  xg = gemini3d.setup.model_setup_interp(cfg);
else
  xg = gemini3d.setup.model_setup_equilibrium(cfg);
end

if ~nargout, clear('cfg', 'xg'), end
end % function
