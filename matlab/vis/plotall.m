function xg = plotall(direc, saveplot_fmt, plotfun, xg, parallel)
% PLOTALL plot all Gemini parameters from a simulation output
%
% Parameters
% ----------
% direc: simulation top-level directory
% saveplot_fmt: char or cell: plot saving formats e.g. png, eps, pdf
% plotfun: name or function handle of plotting function to use (advanced users)
% xg: simulation grid (advanced users) this avoids loading huge grids over and over
% visible: logical true/false make plots visible or not (default off when saving to disk to save time)
%
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

if nargin < 5, parallel = false; end
validateattributes(parallel, {'numeric'}, {'scalar'}, mfilename, 'plot in parallel (lots of RAM for big simulations)', 5)


visible = isempty(saveplot_fmt);

lxs = simsize(direc);
disp(['sim grid dimensions: ',num2str(lxs)])


%% NEED TO READ INPUT FILE TO GET DURATION OF SIMULATION AND START TIME
params = read_config(direc);

%% CHECK WHETHER WE NEED TO RELOAD THE GRID (check if one is given because this can take a long time)
if isempty(xg)
  xg = readgrid(direc);
end

plotfun = grid2plotfun(plotfun, xg);

%% MAIN FIGURE LOOP
Nt = length(params.times);

h = plotinit(xg, visible);

if ~visible
  if parallel
    % plot and save as fast as possible.
    % NOTE: this plotting is not 'threads' pool compatible, it will crash Matlab.
    % https://www.mathworks.com/help/parallel-computing/choose-between-thread-based-and-process-based-environments.html
    parfor i = 1:Nt
      plotframe(direc, params.times(i), saveplot_fmt, plotfun, xg, h)
    end
  else
    for i = 1:Nt
      plotframe(direc, params.times(i), saveplot_fmt, plotfun, xg, h)
    end
  end
elseif isinteractive
  % displaying interactively, not saving
  for t = params.times
    plotframe(direc, t, saveplot_fmt, plotfun, xg, h)

    drawnow % need this here to ensure plots update (race condition)
    fprintf('\n *** press any key to plot next time step, or Ctrl C to stop ***\n')
    pause
  end
else
  error('plotall:runtime_error', 'No Matlab desktop so cannot plot. Was also not told to save')
end % if saveplots

if is_folder(fullfile(direc, 'aurmaps')) % glow sim
  plotglow(direc, saveplot_fmt, visible)
end

%% Don't print
if nargout==0, clear('xg'), end

end % function
