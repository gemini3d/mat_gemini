function h = plot(direc, saveplot_fmt, opts)
%% Plot all quanities for all times in the simulation
%
% Parameters
% ---------
% direc: top-level path of simulation
% saveplot_fmt: 'png' or 'eps' to save. If empty do not save.

arguments
  direc (1,1) string
  saveplot_fmt (1,:) string = string.empty
  opts.parallel (1,1) {mustBeInteger,mustBeFinite} = 0
  opts.xg struct = struct.empty
  opts.plotfun string = string.empty
end

%% ensure all paths are OK
cwd = fileparts(mfilename('fullpath'));
run(fullfile(cwd, '../setup.m'))
%% internal plot
h = gemini3d.plot.plotall(direc, saveplot_fmt, ...
      "plotfun", opts.plotfun, ...
      "xg", opts.xg, ...
      "parallel", opts.parallel);
if nargout == 0, clear('h'), end
end % function
