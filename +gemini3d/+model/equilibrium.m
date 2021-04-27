function xg = equilibrium(cfg)
%% setup equilibrium simulation

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

gemini3d.write.grid(cfg, xg);

%% Equilibrium input generation

ics = gemini3d.model.eqICs(cfg, xg);
% Note: should be rewritten to include the neutral module form the fortran code
gemini3d.write.state(cfg.indat_file, ics, cfg.file_format);

end % function
