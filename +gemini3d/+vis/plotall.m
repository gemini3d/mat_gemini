function h = plotall(direc, saveplot_fmt, options)
% PLOTALL plot all Gemini parameters from a simulation output
%
% Parameters
% ----------
% direc: simulation top-level directory
% saveplot_fmt: char or cell: plot saving formats e.g. png, eps, pdf
% plotfun: name or function handle of plotting function to use (advanced users)
% xg: simulation grid (advanced users) this avoids loading huge grids over and over
% parallel: parallel plotting option:
%   0: plot serially (not in parallel)
%   1: auto-determine number of workers ~ number of CPU cores -- lots of RAM used but fast
%   2..inf: request specific number of workers--useful if you get "out of memory" errors

arguments
  direc (1,1) string
  saveplot_fmt (1,:) string = string.empty
  options.plotfun string = string.empty
  options.xg struct = struct.empty
  options.parallel (1,1) {mustBeInteger,mustBeFinite} = 0
end

visible = isempty(saveplot_fmt);
direc = gemini3d.fileio.expanduser(direc);

lxs = gemini3d.simsize(direc);
disp("sim grid dimensions: " + num2str(lxs))

%% NEED TO READ INPUT FILE TO GET DURATION OF SIMULATION AND START TIME
params = gemini3d.read_config(direc);

%% CHECK WHETHER WE NEED TO RELOAD THE GRID (check if one is given because this can take a long time)
if isempty(options.xg)
  xg = gemini3d.readgrid(direc);
else
  xg = options.xg;
end

plotfun = gemini3d.vis.grid2plotfun(options.plotfun, xg);

%% MAIN FIGURE LOOP
Nt = length(params.times);

h = gemini3d.vis.plotinit(xg, visible);
times = params.times;

if ~visible
  if options.parallel > 0
    % plot and save as fast as possible.
    % NOTE: this plotting is not 'threads' pool compatible, it will crash Matlab.
    % https://www.mathworks.com/help/parallel-computing/choose-between-thread-based-and-process-based-environments.html
    if options.parallel > 1
      % specific number of workers requested
      addons = matlab.addons.installedAddons();
      if any(contains(addons.Name, 'Parallel Computing Toolbox'))
        pool = gcp('nocreate');
        if isempty(pool) || pool.NumWorkers ~= options.parallel
          delete(pool)
          parpool('local', options.parallel)
        end
      end
    end
    parfor i = 1:Nt
      gemini3d.vis.plotframe(direc, times(i), saveplot_fmt, "plotfun", plotfun, "xg", xg, "figures", h)
    end
  else
    for i = 1:Nt
      gemini3d.vis.plotframe(direc, times(i), saveplot_fmt, "plotfun", plotfun, "xg", xg, "figures", h)
    end
  end
else
  % displaying, not saving
  for t = times
    gemini3d.vis.plotframe(direc, t, saveplot_fmt, "plotfun", plotfun, "xg", xg, "figures", h)

    drawnow % need this here to ensure plots update (race condition)
    if gemini3d.sys.isinteractive && times(end) ~= t
      q = input('\n *** press Enter to plot next time step, or "q" Enter to stop ***\n', 's');
      if ~isempty(q), break, end
    end
  end
end % if saveplots

if isfolder(fullfile(direc, "aurmaps")) % glow sim
  gemini3d.vis.plotglow(direc, saveplot_fmt, visible)
end

%% Don't print
if nargout==0, clear('h'), end

end % function
