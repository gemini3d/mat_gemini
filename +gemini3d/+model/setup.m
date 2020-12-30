function [cfg, xg] = setup(cfg, out_dir)
%% determines what kind of setup is needed and does it.
arguments
  cfg
  out_dir string = string.empty
end

%% parse input
if ~isstruct(cfg)
  % path to config.nml
  cfg = gemini3d.read.config(cfg);
end

if isempty(out_dir)
  if ~isfield(cfg, 'outdir') || isempty(cfg.outdir)
    error('model:setup:file_not_found', 'please specify out_dir')
  end
else
  % override with out_dir regardless
  cfg.outdir = out_dir;
end

cfg = gemini3d.fileio.make_valid_paths(cfg);

gemini3d.fileio.makedir(cfg.input_dir)
disp("copying config.nml to " + cfg.input_dir)
% specify filename in case it wasn't config.nml
gemini3d.fileio.copyfile(cfg.nml, fullfile(cfg.input_dir, "config.nml"))


%% is this equilibrium or interpolated simulation
if isfield(cfg, 'eq_dir') && ~isempty(cfg.eq_dir)
  xg = gemini3d.model.interp(cfg);
else
  xg = gemini3d.model.equilibrium(cfg);
end

if ~nargout, clear('cfg', 'xg'), end
end % function
