function xg = model_setup_equilibrium(p)
%% setup equilibrium simulation
% this is to be called by model_setup.m
arguments
  p (1,1) struct
end
%% GRID GENERATION
xg = gemini3d.setup.gridgen.makegrid_cart_3D(p);

gemini3d.writegrid(p, xg);

%% Equilibrium input generation

[ns,Ts,vsx1] = gemini3d.setup.eqICs3D(p, xg);
% Note: should be rewritten to include the neutral module form the fortran code
gemini3d.writedata(p.times(1), ns, vsx1, Ts, p.indat_file, p.file_format);

end % function
