function plotframe(direc, time_req, saveplot_fmt, plotfun, xg, h, visible)
%% CHECK ARGS AND SET SOME DEFAULT VALUES ON OPTIONAL ARGS
arguments
  direc (1,1) string
  time_req (1,1) datetime
  saveplot_fmt (1,:) string = string([])
  plotfun (1,1) function_handle = []
  xg (1,1) struct = struct()
  h (1,:) matlab.ui.Figure = []
  visible (1,1) logical = true
end

import gemini3d.vis.*
import gemini3d.vis.plotfunctions.*

Ncmap = parula(256);
Tcmap = parula(256);
Phi_cmap = bwr();
Vcmap = bwr();
Jcmap = bwr();

lotsplots = true;   %@scivision may want to fix this...
% FIXME: VALIDATE THE INPUT DATA...

%% SET THE CAXIS LIMITS FOR THE PLOTS - really needs to be user provided somehow...
flagcaxlims=false;
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

%% READ IN THE SIMULATION INFORMATION (this is low cost so reread no matter what)
p = gemini3d.read_config(direc);

%% CHECK WHETHER WE NEED TO RELOAD THE GRID (check if one is given because this can take a long time)
if isempty(fieldnames(xg))
  disp('plotframe: Reloading grid...  Provide one as input if you do not want this to happen.')
  xg = gemini3d.readgrid(fullfile(direc, "inputs"));
end

if isempty(h)
  h = gemini3d.vis.plotinit(xg, visible);
end

plotfun = gemini3d.vis.grid2plotfun(plotfun, xg);

%% LOCATE TIME index NEAREST TO THE REQUESTED DATE=
i = interp1(p.times, 1:length(p.times), time_req, 'nearest');
time = p.times(i);
%% LOAD THE FRAME NEAREST TO THE REQUESTED TIME
dat = gemini3d.vis.loadframe(direc, time);
disp(dat.filename + ' => ' + func2str(plotfun))

%% UNTIL WE PROVIDE A WAY FOR THE USER TO SPECIFY COLOR AXES, JUST TRY TO SET THEM AUTOMATICALLY
if (~flagcaxlims)
 nelim =  [min(dat.ne(:)), max(dat.ne(:))];
% v1mod=max(abs(v1(:)));
 v1mod=80;
 v1lim = [-v1mod, v1mod];
 Tilim = [0, max(dat.Ti(:))];
 Telim = [0, max(dat.Te(:))];
 J1mod=max(abs(dat.J1(:)));
 J1lim = [-J1mod, J1mod];
 v2mod=max(abs(dat.v2(:)));
 v2lim = [-v2mod, v2mod];
 v3mod=max(abs(dat.v3(:)));
 v3lim = [-v3mod, v3mod];
 J2mod=max(abs(dat.J2(:)));
 J2lim = [-J2mod, J2mod];
 J3mod=max(abs(dat.J3(:)));
 J3lim=[-J3mod, J3mod];
 Phitop_lim = [min(dat.Phitop(:)), max(dat.Phitop(:))];
%   v1lim = [NaN,NaN];
%   Tilim = [0, max(Ti(:))];
%   Telim = [0, max(Te(:))];
%   J1lim = [NaN,NaN];
%   v2lim = [NaN,NaN];
%   v3lim = [NaN,NaN];
%   J2lim = [NaN,NaN];
%   J3lim=[NaN,NaN];
end

%% MAKE THE PLOTS (WHERE APPROPRIATE)
%Electron number density, 'position', [.1, .1, .5, .5], 'units', 'normalized'
if lotsplots   % 3D simulation or a very long 2D simulation - do separate plots for each time frame

clf(h(10))
plotfun(time, xg, dat.ne, 'n_e (m^{-3})', nelim,[p.sourcemlat,p.sourcemlon], h(10), Ncmap);

if p.flagoutput ~= 3
  clf(h(1))
  plotfun(time, xg, dat.v1, 'v_1 (m/s)', v1lim,[p.sourcemlat,p.sourcemlon], h(1), Vcmap);
  clf(h(2))
  plotfun(time, xg, dat.Ti,'T_i (K)',Tilim,[p.sourcemlat,p.sourcemlon], h(2), Tcmap);
  clf(h(3))
  plotfun(time, xg, dat.Te,'T_e (K)',Telim,[p.sourcemlat,p.sourcemlon], h(3), Tcmap);
  clf(h(4))
  plotfun(time, xg, dat.J1,'J_1 (A/m^2)',J1lim,[p.sourcemlat,p.sourcemlon],h(4), Jcmap);
  clf(h(5))
  plotfun(time, xg, dat.v2,'v_2 (m/s)',v2lim,[p.sourcemlat,p.sourcemlon],h(5), Vcmap);
  clf(h(6))
  plotfun(time, xg, dat.v3,'v_3 (m/s)',v3lim,[p.sourcemlat,p.sourcemlon],h(6), Vcmap);
  clf(h(7))
  plotfun(time, xg, dat.J2,'J_2 (A/m^2)',J2lim,[p.sourcemlat,p.sourcemlon],h(7), Jcmap);
  clf(h(8))
  plotfun(time, xg, dat.J3,'J_3 (A/m^2)',J3lim,[p.sourcemlat,p.sourcemlon],h(8), Jcmap);
  clf(h(9))
%   try
  plotfun(time, xg, dat.Phitop,'topside potential \Phi_{top} (V)', Phitop_lim, [p.sourcemlat, p.sourcemlon], h(9), Phi_cmap)
%   catch e
%     % casting an error to warning requires this syntax for Matlab < R2020a
%     warning(e.identifier, '%s', e.message)
%   end
end

else    %short 2D simulation - put the entire time series in a single plot

figure(h(10)) %#ok<*UNRCH>
Rsp = 4;
Csp = 3;
ha = subplot(Rsp, Csp, it, 'parent',h(10));
nelim =  [9 11.3];
plotfun(time, xg,log10(ne), 'log_{10} n_e (m^{-3})',nelim,[p.sourcemlat,p.sourcemlon],ha);

if p.flagoutput ~= 3
  ha = subplot(Rsp, Csp,it,'parent',h(1));
  plotfun(time, xg, dat.v1(:,:,:),'v_1 (m/s)',v1lim,[p.sourcemlat,p.sourcemlon],ha);

  ha = subplot(Rsp, Csp,it,'parent',h(2));
  plotfun(time, xg, dat.Ti(:,:,:),'T_i (K)',Tilim,[p.sourcemlat,p.sourcemlon],ha);

  ha = subplot(Rsp, Csp,it,'parent',h(3));
  plotfun(time, xg, dat.Te(:,:,:),'T_e (K)',Telim,[p.sourcemlat,p.sourcemlon],ha);

  ha = subplot(Rsp, Csp,it,'parent',h(4));
  plotfun(time, xg, dat.J1(:,:,:),'J_1 (A/m^2)',J1lim,[p.sourcemlat,p.sourcemlon],ha);

  ha = subplot(Rsp, Csp,it,'parent',h(5));
  plotfun(time, xg, dat.v2(:,:,:),'v_2 (m/s)',v2lim,[p.sourcemlat,p.sourcemlon],ha);

  ha = subplot(Rsp, Csp,it,'parent',h(6));
  plotfun(time, xg, dat.v3(:,:,:),'v_3 (m/s)',v3lim,[p.sourcemlat,p.sourcemlon],ha);

  ha = subplot(Rsp, Csp,it,'parent',h(7));
  plotfun(time, xg, dat.J2(:,:,:),'J_2 (A/m^2)',J2lim,[p.sourcemlat,p.sourcemlon],ha);

  ha = subplot(Rsp, Csp,it,'parent',h(8));
  plotfun(time, xg, dat.J3(:,:,:),'J_3 (A/m^2)',J3lim,[p.sourcemlat,p.sourcemlon],ha);

  ha = subplot(Rsp, Csp,it,'parent',h(9));

%  plotfun(time, xg, dat.Phitop,'topside potential \Phi_{top} (V)', Phitop_lim, [p.sourcemlat, p.sourcemlon], h(9, Phi_cmap)
end

end


if lotsplots && ~isempty(saveplot_fmt)
  % for 3D or long 2D plots print and output file every time step
  gemini3d.vis.saveframe(p.flagoutput, direc, dat.filename, saveplot_fmt, h)
end

end % function plotframe
