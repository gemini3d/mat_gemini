function xg = plotall(direc, saveplot_fmt, plotfun, xg, parallel)
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
import gemini3d.vis.*

narginchk(1,5)

validateattributes(direc, {'char'}, {'vector'}, mfilename, 'path to data', 1)

if nargin<2, saveplot_fmt={}; end  %e.g. {'png'} or {'png', 'eps'}

if nargin<3, plotfun=[]; end
if ~isempty(plotfun)
  validateattributes(plotfun, {'char', 'function_handle'}, {'nonempty'}, mfilename, 'plotting function',3)
end

if nargin<4, xg=[]; end
if ~isempty(xg)
  validateattributes(xg, {'struct'}, {'scalar'}, mfilename, 'grid structure', 4)
end

if nargin < 5, parallel =0; end
validateattributes(parallel, {'numeric'}, {'scalar'}, mfilename, 'Number of tasks to plot in parallel (lots of RAM for big simulations)', 5)

visible = isempty(saveplot_fmt);

lxs = gemini3d.simsize(direc);
disp(['sim grid dimensions: ',num2str(lxs)])


%% NEED TO READ INPUT FILE TO GET DURATION OF SIMULATION AND START TIME
params = gemini3d.read_config(direc);

%% CHECK WHETHER WE NEED TO RELOAD THE GRID (check if one is given because this can take a long time)
if isempty(xg)
  xg = gemini3d.readgrid(direc);
end

plotfun = grid2plotfun(plotfun, xg);

%% MAIN FIGURE LOOP
Nt = length(params.times);

h = plotinit(xg, visible);

if ~visible
  if parallel > 0
    % plot and save as fast as possible.
    % NOTE: this plotting is not 'threads' pool compatible, it will crash Matlab.
    % https://www.mathworks.com/help/parallel-computing/choose-between-thread-based-and-process-based-environments.html
    if parallel > 1
      % specific number of workers requested
      addons = matlab.addons.installedAddons();
      if any(contains(addons.Name, 'Parallel Computing Toolbox'))
        pool = gcp('nocreate');
        if isempty(pool) || pool.NumWorkers ~= parallel
          delete(pool)
          parpool('local', parallel)
        end
      end
    end
    parfor i = 1:Nt
      plotframe(direc, params.times(i), saveplot_fmt, plotfun, xg, h)
    end
  else
    for i = 1:Nt
      plotframe(direc, params.times(i), saveplot_fmt, plotfun, xg, h)
    end
  end
else
  % displaying, not saving
  for t = params.times
    plotframe(direc, t, saveplot_fmt, plotfun, xg, h)

    drawnow % need this here to ensure plots update (race condition)
    if gemini3d.sys.isinteractive && params.times(end) ~= t
      q = input('\n *** press Enter to plot next time step, or "q" Enter to stop ***\n', 's');
      if ~isempty(q), break, end
    end
  end
end % if saveplots

if isfolder(fullfile(direc, 'aurmaps')) % glow sim
  plotglow(direc, saveplot_fmt, visible)
end

%% Don't print
if nargout==0, clear('xg'), end

end % function
