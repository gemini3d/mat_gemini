function xg = interp(cfg)
%% setup interpolated simulation based on equilibrium simulation

arguments
  cfg (1,1) struct
end

%% GRID GENERATION
if all(isfield(cfg, ["lxp", "lyp"]))
  xg = gemini3d.grid.cartesian(cfg);
elseif all(isfield(cfg, ["lq", "lp", "lphi"]))
  xg = gemini3d.grid.tilted_dipole(cfg);
else
  error("grid does not seems to be cartesian or curvilinear")
end

gemini3d.model.eq2dist(cfg, xg);

gemini3d.model.postprocess(cfg, xg)
end % function
