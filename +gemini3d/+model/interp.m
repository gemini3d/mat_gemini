function xg = interp(cfg)
%% setup interpolated simulation based on equilibrium simulation

arguments
  cfg (1,1) struct
end

%% GRID GENERATION
xg = gemini3d.grid.cart3d(cfg);

gemini3d.model.eq2dist(cfg, xg);

gemini3d.model.postprocess(cfg, xg)
end % function
