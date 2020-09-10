function xg = model_setup_equilibrium(cfg)
%% setup equilibrium simulation
% this is to be called by model_setup.m
arguments
  cfg (1,1) struct
end
%% GRID GENERATION
xg = gemini3d.setup.gridgen.makegrid_cart_3D(cfg);

gemini3d.writegrid(cfg, xg);

%% Equilibrium input generation

[ns,Ts,vsx1] = gemini3d.setup.eqICs3D(cfg, xg);
% Note: should be rewritten to include the neutral module form the fortran code
gemini3d.writedata(cfg.times(1), ns, vsx1, Ts, cfg.indat_file, cfg.file_format);

end % function
