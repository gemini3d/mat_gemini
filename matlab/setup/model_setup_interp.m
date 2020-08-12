function xg = model_setup_interp(p)
%% setup interpolated simulation based on equilibrium simulation
% this is to be called by model_setup.m
narginchk(1,1)
validateattributes(p, {'struct'}, {'scalar'}, mfilename, 'parameters', 1)

%% GRID GENERATION
xg = makegrid_cart_3D(p);

eq2dist(p, xg);

%% potential boundary conditions
if isfield(p, 'E0_dir')
  Efield_BCs(p, xg);
end

%% aurora
if isfield(p, 'prec_dir')
  particles_BCs(p, xg)
end

end % function
