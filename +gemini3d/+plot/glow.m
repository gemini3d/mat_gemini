function glow(direc, time, saveplot_fmt, opts)
% plots Gemini-Glow auroral emissions
arguments
  direc (1,:) string
  time (1,1) datetime
  saveplot_fmt (1,:) string = string.empty
  opts.xg (1,1) struct
  opts.figure matlab.ui.Figure
end

if isempty(direc)
  return
end

parent = fileparts(direc);

%array of volume emission rates at each altitude; cm-3 s-1:
wavelengths = ["3371", "4278", "5200", "5577", "6300", "7320", "10400", ...
  "3466", "7774", "8446", "3726", "LBH", "1356", "1493", "1304"];

%READ IN SIMULATION INFO
cfg = gemini3d.read.config(parent);

%READ IN THE GRID
if isfield(opts, "xg")
  xg = opts.xg;
else
  xg = gemini3d.read.grid(parent);
end

%% GET THE SYSTEM SIZE
Lw = length(wavelengths);
lx2=xg.lx(2);
lx3=xg.lx(3);
x2=xg.x2(3:end-2);
x3=xg.x3(3:end-2);

%% get filename
fn = gemini3d.find.frame(direc, time);

%% make plots
if isfield(opts, "figure")
  fg = opts.figure;
else
  fg = make_glowfig(isempty(saveplot_fmt));
end

bFrame = squeeze(loadglow_aurmap(fn, lx2, lx3, Lw));
t_str = string(time) + " UT";

if lx2 > 1 && lx3 > 1
  % 3D sim
  emission_line(x2, x3, bFrame, t_str, wavelengths, fg);
elseif lx2 > 1
   % 2D east-west
  emissions(x2, wavelengths, bFrame, t_str, fg, "Eastward");
elseif lx3 > 1
  % 2D north-south
  emissions(x3, wavelengths, bFrame, t_str, fg, "Northward");
else
  error("gemini3d:plot:glow", 'impossible GLOW configuration')
end

if cfg.flagoutput ~= 3
  gemini3d.plot.save_glowframe(fg, fn, saveplot_fmt)
end

end % function


function emissions(x, wavelengths, bFrame, time_str, hf, txt)
arguments
  x (:,1) {mustBeReal}
  wavelengths (1,:) string
  bFrame (:,:) {mustBeReal}
  time_str (1,1) string
  hf (1,1) matlab.ui.Figure
  txt (1,1) string
end

clf(hf)

ax = axes('parent', hf);
imagesc(ax, 1:length(wavelengths), x / 1e3, bFrame)    % singleton dimension since 2D simulation
set(ax, 'xtick', 1:length(wavelengths), 'xticklabel', wavelengths)

ylabel(ax, txt + "Distance (km)")

xlabel(ax, 'emission wavelength (\AA)', 'interpreter', 'latex')
title(ax, time_str)
hc = colorbar('peer', ax);
ylabel(hc, 'Intensity (R)')
end


function emission_line(x2, x3, bFrame, time_str, wavelengths, hf)
arguments
  x2 (:,1) {mustBeReal}
  x3 (1,:) {mustBeReal}
  bFrame (:,:,:) {mustBeReal}
  time_str (1,1) string
  wavelengths (1,:) string
  hf (1,1) matlab.ui.Figure
end

clf(hf)

% arbitrary pick of which emission lines to plot lat/lon slices
inds = [2, 4, 5, 9];

t = tiledlayout(length(inds), 1, 'parent', hf);

for i=1:length(inds)
  ax = nexttile(t);
  imagesc(ax, x2/1e3, x3/1e3, squeeze(bFrame(:,:,inds(i)))');
  axis(ax, 'xy')
  axis(ax, 'tight')
  %caxis(caxlims);
  cb = colorbar('peer', ax);
  %set(cb,'yticklabel',sprintf('10^{%g}|', get(cb,'ytick')))
  ylabel(cb,'Intensity (R)')
  title(ax, wavelengths(inds(i)) + "\AA  intensity: " + time_str, 'interpreter', 'latex')

  xlabel(ax, 'Eastward Distance (km)')
  ylabel(ax, 'Northward Distance (km)')
end

end % function


%ffmpeg -framerate 10 -pattern_type glob -i '*.png' -c:v libxvid -r 30 -q:v 0 isinglass_geminiglow_4278.avi
%ffmpeg -framerate 10 -pattern_type glob -i '*.png' -c:v libx264 -r 30 -pix_fmt yuv420p out.mp4
