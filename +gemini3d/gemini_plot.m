function h = gemini_plot(direc, saveplot_fmt, options)
%% Plot all quanities for all times in the simulation
%
% Parameters
% ---------
% direc: top-level path of simulation
% saveplot_fmt: 'png' or 'eps' to save. If empty do not save.

arguments
  direc (1,1) string
  saveplot_fmt (1,:) string = string.empty
  options.parallel (1,1) {mustBeInteger,mustBeFinite} = 0
  options.xg struct = struct.empty
  options.plotfun string = string.empty
end

h = gemini3d.vis.plotall(direc, saveplot_fmt, ...
      "plotfun", options.plotfun, ...
      "xg", options.xg, ...
      "parallel", options.parallel);
if nargout == 0, clear('h'), end
end % function
