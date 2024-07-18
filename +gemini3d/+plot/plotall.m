function h = plotall(direc, saveplot_fmt, opts)
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
  opts.plotfun string {mustBeScalarOrEmpty} = string.empty
  opts.xg struct {mustBeScalarOrEmpty} = struct.empty
  opts.parallel (1,1) {mustBeInteger} = 0
end

gemini3d.sys.check_stdlib()

visible = isempty(saveplot_fmt);
direc = stdlib.expanduser(direc);

lxs = gemini3d.simsize(direc);
disp("sim grid dimensions: " + num2str(lxs))

%% NEED TO READ INPUT FILE TO GET DURATION OF SIMULATION AND START TIME
cfg = gemini3d.read.config(direc);
if isempty(cfg)
  error("gemini3d:plotall:fileNotFound", "%s does not contain Gemini3D data", direc)
end
%% CHECK WHETHER WE NEED TO RELOAD THE GRID (check if one is given because this can take a long time)
if isempty(opts.xg)
  xg = gemini3d.read.grid(direc);
else
  xg = opts.xg;
end

%% determine plotting function
if isempty(opts.plotfun)
  plotfun = gemini3d.plot.grid2plotfun(xg);
else
  plotfun = str2func("gemini3d.plot." + opts.plotfun);
end

%% determine if GLOW
if isfield(cfg, "aurmap_dir")
  % glow sim
  if stdlib.is_absolute(cfg.aurmap_dir)
    aurmap_dir = cfg.aurmap_dir;
  else
    aurmap_dir = fullfile(direc, cfg.aurmap_dir);
  end
  hglow = make_glowfig(visible);
else
  aurmap_dir = string.empty;
  hglow = matlab.ui.Figure.empty;
end

%% MAIN FIGURE LOOP
h = gemini3d.plot.init(xg, visible);

if ~visible
  if opts.parallel > 0
    % plot and save as fast as possible.
    % NOTE: this plotting is not 'threads' pool compatible, it will crash Matlab.
    % https://www.mathworks.com/help/parallel-computing/choose-between-thread-based-and-process-based-environments.html
    if opts.parallel > 1
      % specific number of workers requested
      if gemini3d.sys.has_parallel()
        pool = gcp('nocreate');
        if isempty(pool) || pool.NumWorkers ~= optfions.parallel
          delete(pool)
          parpool('local', opts.parallel)
        end
      end
    end
    parfor t = cfg.times
      gemini3d.plot.frame(direc, t, saveplot_fmt, "plotfun", plotfun, "xg", xg, "figures", h)
      gemini3d.plot.glow(aurmap_dir, t, saveplot_fmt, "xg", xg, "figure", hglow)
    end
  else
    for t = cfg.times
      gemini3d.plot.frame(direc, t, saveplot_fmt, "plotfun", plotfun, "xg", xg, "figures", h)
      gemini3d.plot.glow(aurmap_dir, t, saveplot_fmt, "xg", xg, "figure", hglow)
    end
  end
else
  % displaying, not saving
  for t = cfg.times
    gemini3d.plot.frame(direc, t, saveplot_fmt, "plotfun", plotfun, "xg", xg, "figures", h)
    gemini3d.plot.glow(aurmap_dir, t, saveplot_fmt, "xg", xg, "figure", hglow)

    drawnow % need this here to ensure plots update (race condition)
    if gemini3d.sys.isinteractive && cfg.times(end) ~= t
      q = input('\n *** press Enter to plot next time step, or "q" Enter to stop ***\n', 's');
      if ~isempty(q), break, end
    end
  end
end % if saveplots


%% Don't print
if nargout==0, clear('h'), end

end % function
