function h = frame(direc, time_req, saveplot_fmt, opts)
%% CHECK ARGS AND SET SOME DEFAULT VALUES ON OPTIONAL ARGS
arguments
  direc (1,1) string
  time_req (1,1) datetime
  saveplot_fmt (1,:) string = string.empty
  opts.plotfun (1,1)
  opts.xg struct {mustBeScalarOrEmpty} = struct.empty
  opts.figures (1,:) matlab.ui.Figure
  opts.visible (1,1) logical = true
  opts.clim (1,1) struct = struct()  % not .empty
  % opts.vars (1,:) string = string.empty  % variables to plot (future)
end

import gemini3d.plot.bwr

Ncmap = parula(256);
Tcmap = parula(256);
Phi_cmap = bwr();
Vcmap = bwr();
Jcmap = bwr();

%% READ IN THE SIMULATION INFORMATION (this is low cost so reread no matter what)
cfg = gemini3d.read.config(direc);

%% RELOAD GRID?
% loading grid can take a long time
if isempty(opts.xg)
  disp('plot.frame: Reloading grid...  Provide one as input if you do not want this to happen.')
  xg = gemini3d.read.grid(direc);
else
  xg = opts.xg;
end

if isfield(opts, "figures") && all(isvalid(opts.figures))
  h = opts.figures;
else
  h = gemini3d.plot.init(xg, opts.visible);
end

if isfield(opts, "plotfun")
  plotfun = opts.plotfun;
else
  plotfun = gemini3d.plot.grid2plotfun(xg);
end

%% get time index
i = interp1(cfg.times, 1:length(cfg.times), time_req, 'nearest');
if isnan(i)
  error('plot:frame:value_error', "requested time " + string(time_req) + " is outside simulation time span " + string(cfg.times(1)) + " " + string(cfg.times(end)))
end
time = cfg.times(i);
%% LOAD THE FRAME NEAREST TO THE REQUESTED TIME
dat = gemini3d.read.frame(direc, time=time);
disp(dat.filename + ' => ' + func2str(plotfun))

%% SET THE Color LIMITS FOR THE PLOTS
%{
nelim =  [0 6e11];
v1lim = [-400 400];
Tilim = [100 3000];
Telim = [100 3000];
J1lim = [-25 25];
v2lim = [-10 10];
v3lim = [-10 10];
J2lim = [-10 10];
J3lim=[-10 10];
%}

clm = opts.clim;
if ~isfield(clm, "ne") && isfield(dat, 'ne')
  clm.ne = [min(dat.ne, [], 'all'), max(dat.ne, [], 'all')];
end
if ~isfield(clm, "v1") && isfield(dat, 'v1')
% v1mod=max(abs(v1), [], 'all'));
  v1mod = 80;
  clm.v1 = [-v1mod, v1mod];
end
if ~isfield(clm, "Ti") && isfield(dat, 'Ti')
  clm.Ti = [0, max(dat.Ti, [], 'all')];
end
if ~isfield(clm, "Te") && isfield(dat, 'Te')
  clm.Te = [0, max(dat.Te, [], 'all')];
end
if ~isfield(clm, "J1") && isfield(dat, 'J1')
  J1mod = max(abs(dat.J1), [], 'all');
  clm.J1 = [-J1mod, J1mod];
end
if ~isfield(clm, "v2") && isfield(dat, 'v2')
  v2mod = max(abs(dat.v2), [], 'all');
  clm.v2 = [-v2mod, v2mod];
end
if ~isfield(clm, "v3") && isfield(dat, 'v3')
  v3mod = max(abs(dat.v3), [], 'all');
  clm.v3 = [-v3mod, v3mod];
end
if ~isfield(clm, "J2") && isfield(dat, 'J2')
  J2mod = max(abs(dat.J2), [], 'all');
  clm.J2 = [-J2mod, J2mod];
end
if ~isfield(clm, "J3") && isfield(dat, 'J3')
  J3mod = max(abs(dat.J3), [], 'all');
  clm.J3 = [-J3mod, J3mod];
end
if ~isfield(clm, "Phitop") && isfield(dat, 'Phitop')
  clm.Phitop = [min(dat.Phitop, [], 'all'), max(dat.Phitop, [], 'all')];
end

%% MAKE THE PLOTS

clf(h(10))
if isfield(dat, 'ne')
  plotfun(time, xg, dat.ne, 'n_e (m^{-3})', clm.ne, [cfg.sourcemlat,cfg.sourcemlon], h(10), Ncmap);
end

if cfg.flagoutput ~= 3
  clf(h(1))
  if isfield(dat, 'v1')
    plotfun(time, xg, dat.v1, 'v_1 (m/s)', clm.v1, [cfg.sourcemlat,cfg.sourcemlon], h(1), Vcmap);
    clf(h(2))
  end
  if isfield(dat, 'Ti')
    plotfun(time, xg, dat.Ti,'T_i (K)', clm.Ti, [cfg.sourcemlat,cfg.sourcemlon], h(2), Tcmap);
    clf(h(3))
  end
  if isfield(dat, 'Te')
    plotfun(time, xg, dat.Te,'T_e (K)', clm.Te, [cfg.sourcemlat,cfg.sourcemlon], h(3), Tcmap);
    clf(h(4))
  end
  if isfield(dat, 'J1')
    plotfun(time, xg, dat.J1, 'J_1 (A/m^2)', clm.J1, [cfg.sourcemlat,cfg.sourcemlon],h(4), Jcmap);
    clf(h(5))
  end
  if isfield(dat, 'v2')
    plotfun(time, xg, dat.v2,'v_2 (m/s)', clm.v2, [cfg.sourcemlat,cfg.sourcemlon],h(5), Vcmap);
    clf(h(6))
  end
  if isfield(dat, 'v3')
    plotfun(time, xg, dat.v3,'v_3 (m/s)', clm.v3, [cfg.sourcemlat,cfg.sourcemlon],h(6), Vcmap);
    clf(h(7))
  end
  if isfield(dat, 'J2')
    plotfun(time, xg, dat.J2,'J_2 (A/m^2)', clm.J2, [cfg.sourcemlat,cfg.sourcemlon],h(7), Jcmap);
    clf(h(8))
  end
  if isfield(dat, 'J3')
    plotfun(time, xg, dat.J3,'J_3 (A/m^2)', clm.J3, [cfg.sourcemlat,cfg.sourcemlon],h(8), Jcmap);
    clf(h(9))
  end
  if isfield(dat, 'Phitop')  && xg.lx(3)>1   %problems with potential in 2D???
    plotfun(time, xg, dat.Phitop,'topside potential \Phi_{top} (V)', clm.Phitop, [cfg.sourcemlat, cfg.sourcemlon], h(9), Phi_cmap)
  end
%   catch e
%     % casting an error to warning requires this syntax for Matlab < R2020a
%     warning(e.identifier, '%s', e.message)
%   end
end

gemini3d.plot.saveframe(cfg.flagoutput, direc, dat.filename, saveplot_fmt, h)

if nargout == 0, clear('h'), end

end % function plotframe
