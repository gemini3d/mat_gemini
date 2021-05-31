function [cfg, xg] = setup(cfg, out_dir)
%% setup(cfg, out_dir)
% sets up initial conditions for Gemini3D simulation
arguments
  cfg {mustBeA(cfg, ["string", "char", "struct"])}
  out_dir string = string.empty
end

import gemini3d.fileio.make_valid_paths
import stdlib.fileio.makedir
import stdlib.fileio.copyfile

assert(~verLessThan('matlab', '9.7'), 'Matlab >= R2019b is required')

%% parse input
if ~isstruct(cfg)
  % path to config.nml
  cfg = gemini3d.read.config(cfg, true);
end

if ~isempty(out_dir)
  cfg.outdir = out_dir;
end

cfg = make_valid_paths(cfg);

makedir(cfg.input_dir)
disp("copying config.nml to " + cfg.input_dir)
% specify filename in case it wasn't config.nml
copyfile(cfg.nml, fullfile(cfg.input_dir, "config.nml"))


%% is this equilibrium or interpolated simulation
if isfield(cfg, 'eq_dir') && ~isempty(cfg.eq_dir)
  xg = gemini3d.model.interp(cfg);
else
  xg = gemini3d.model.equilibrium(cfg);
end

if ~nargout, clear('cfg', 'xg'), end
end % function
