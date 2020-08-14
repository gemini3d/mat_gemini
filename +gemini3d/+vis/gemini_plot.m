function gemini_plot(direc, saveplot_fmt, parallel, xg, plotfun)
%% Plot all quanities for all times in the simulation
%
% Parameters
% ---------
% simulation_dir: top-level path of simulation
% save_Format: 'png' or 'eps' to save. If empty do not save.

narginchk(1,5)

if nargin < 2, saveplot_fmt = {}; end
if nargin < 3, parallel = 0; end
if nargin < 4, xg = []; end
if nargin < 5, plotfun = []; end

gemini3d.vis.plotall(direc, saveplot_fmt, plotfun, xg, parallel)

end % function
