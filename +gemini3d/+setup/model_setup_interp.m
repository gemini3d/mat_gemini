function xg = model_setup_interp(cfg)
%% setup interpolated simulation based on equilibrium simulation
% this is to be called by model_setup.m
arguments
  cfg (1,1) struct
end

%% GRID GENERATION
xg = gemini3d.setup.gridgen.makegrid_cart_3D(cfg);

gemini3d.setup.eq2dist(cfg, xg);

gemini3d.setup.setup_post_process(cfg, xg)
end % function
