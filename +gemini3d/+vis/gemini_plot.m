function h = gemini_plot(direc, saveplot_fmt, parallel, xg, plotfun)
%% Plot all quanities for all times in the simulation
%
% Parameters
% ---------
% simulation_dir: top-level path of simulation
% save_Format: 'png' or 'eps' to save. If empty do not save.
arguments
  direc (1,1) string
  saveplot_fmt (1,:) string = ""
  parallel (1,1) {mustBeInteger,mustBeFinite} = 0
  xg (1,1) struct = struct()
  plotfun (1,1) string = ""
end

h = gemini3d.vis.plotall(direc, saveplot_fmt, plotfun, xg, parallel);
if nargout == 0, clear('h'), end
end % function
