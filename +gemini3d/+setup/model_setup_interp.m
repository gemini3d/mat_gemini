function xg = model_setup_interp(cfg)
%% setup interpolated simulation based on equilibrium simulation
% this is to be called by model_setup.m
import gemini3d.setup.*

narginchk(1,1)
validateattributes(cfg, {'struct'}, {'scalar'}, mfilename, 'parameters', 1)

%% GRID GENERATION
xg = gemini3d.setup.gridgen.makegrid_cart_3D(cfg);

eq2dist(cfg, xg);

setup_post_process(cfg, xg)
end % function
