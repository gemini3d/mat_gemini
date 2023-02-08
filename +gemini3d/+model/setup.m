function [cfg, xg] = setup(cfg, out_dir)
%% setup(cfg, out_dir)
% sets up initial conditions for Gemini3D simulation
arguments
  cfg {mustBeA(cfg, ["string", "char", "struct"])}
  out_dir string = string.empty
end

gemini3d.sys.check_stdlib()

%% parse input
if ~isstruct(cfg)
  % path to config.nml
  cfg = gemini3d.read.config(cfg);
end

if ~isempty(out_dir)
  cfg.outdir = out_dir;
end

cfg = gemini3d.fileio.make_valid_paths(cfg);

stdlib.makedir(cfg.input_dir)
disp("copying config.nml to " + cfg.input_dir)
% specify filename in case it wasn't config.nml
copyfile(stdlib.expanduser(cfg.nml), ...
stdlib.expanduser(fullfile(cfg.input_dir, "config.nml")))

setup_summary(cfg)

%% is this equilibrium or interpolated simulation
if isfield(cfg, 'eq_dir') && ~isempty(cfg.eq_dir)
  xg = gemini3d.model.interp(cfg);
else
  xg = gemini3d.model.equilibrium(cfg);
end

if ~nargout, clear('cfg', 'xg'), end
end % function
