function plotglow(direc, saveplot_fmt, visible)
% plots Gemini-Glow auroral emissions
narginchk(1,3)

if nargin<3
  if nargin < 2 || isempty(saveplot_fmt)
    visible =true;
  else
    visible = false;
  end
end

if nargin<2, saveplot_fmt={'png'}; end

assert(isfolder(direc), 'not a directory: %s', direc)
aurora_dir = fullfile(direc, 'aurmaps');

%array of volume emission rates at each altitude; cm-3 s-1:
wavelengths = {'3371', '4278', '5200', '5577', '6300', '7320', '10400', ...
  '3466', '7774', '8446', '3726', 'LBH', '1356', '1493', '1304'};

%READ IN SIMULATION INFO
params = gemini3d.read_config(direc);

%READ IN THE GRID
xg = gemini3d.readgrid(direc);

%% GET THE SYSTEM SIZE
lwave=length(wavelengths);
lx2=xg.lx(2);
lx3=xg.lx(3);
x2=xg.x2(3:end-2);
x3=xg.x3(3:end-2);

%% get file list
for ext = {'.h5', '.nc', '.dat'}
  file_list = dir([aurora_dir, '/*', ext{1}]);
  if ~isempty(file_list), break, end
end
assert(~isempty(file_list), ['No auroral data found in ', aurora_dir])

%% make plots
hf = [];
for i = 1:length(file_list)
  filename = fullfile(aurora_dir, file_list(i).name);
  bFrame = gemini3d.vis.loadglow_aurmap(filename, lx2, lx3, lwave);
  t_str = [datestr(params.times(i)), ' UT'];

if lx2 > 1 && lx3 > 1
    % 3D sim
    hf = plot_emission_line(x2, x3, bFrame, t_str, wavelengths, hf, visible);
elseif lx2 > 1
     % 2D east-west
    hf = plot_emissions(x2, wavelengths, bFrame, t_str, hf, visible);
elseif lx3 > 1
     % 2D north-south
    hf = plot_emissions(x3, wavelengths, bFrame, t_str, hf, visible);
else
  error('impossible configuration')
end

  if params.flagoutput ~= 3
    gemini3d.vis.save_glowframe(filename, saveplot_fmt, hf)
  end
end

end % function


function hf = plot_emissions(x, wavelengths, bFrame, time_str, hf, visible)
narginchk(4,6)
validateattributes(x, {'numeric'}, {'vector'}, 1)
validateattributes(bFrame, {'numeric'}, {'nonnegative'}, 3)
validateattributes(wavelengths, {'cell'}, {'vector'}, 2)
if nargin < 6, visible = true; end

if nargin < 5 || isempty(hf)
  hf = make_glowfig(visible);
else
  clf(hf)
end

ax = axes('parent', hf);
imagesc(1:length(wavelengths), x / 1e3,squeeze(bFrame))    % singleton dimension since 2D simulation
set(ax, 'xtick', 1:length(wavelengths), 'xticklabel', wavelengths)
if size(bFrame, 2) == 1
  ylabel(ax, 'Northward Distance (km)')
elseif size(bFrame, 3) == 1
  ylabel(ax, 'Eastward Distance (km)')
end
xlabel(ax, 'emission wavelength (\AA)', 'interpreter', 'latex')
title(ax, time_str)
hc = colorbar('peer', ax);
ylabel(hc, 'Intensity (R)')
end


function hf = plot_emission_line(x2, x3, bFrame, time_str, wavelengths, hf, visible)
narginchk(5,7)
validateattributes(x2, {'numeric'}, {'vector'}, 1)
validateattributes(x3, {'numeric'}, {'vector'}, 2)
validateattributes(bFrame, {'numeric'}, {'ndims', 3}, 3)
validateattributes(time_str, {'char'}, {'vector'}, 4)
validateattributes(wavelengths, {'cell'}, {'vector'}, 5)
if nargin < 7, visible = true; end

if nargin < 5 || isempty(hf)
  hf = make_glowfig(visible);
else
  clf(hf)
end

% arbitrary pick of which emission lines to plot lat/lon slices
inds = [2, 4, 5, 9];

for i=1:length(inds)
  ax = subplot(2,2,i,'parent', hf);
  imagesc(x2/1e3, x3/1e3, squeeze(bFrame(:,:,inds(i)))', 'parent', ax);
  axis(ax, 'xy')
  axis(ax, 'tight')
  %caxis(caxlims);
  cb = colorbar('peer', ax);
  %set(cb,'yticklabel',sprintf('10^{%g}|', get(cb,'ytick')))
  ylabel(cb,'Intensity (R)')
  title(ax, [wavelengths{inds(i)},'\AA  intensity: ', time_str], 'interpreter', 'latex')
end

ax=subplot(2,2,3);
xlabel(ax, 'Eastward Distance (km)')
ylabel(ax, 'Northward Distance (km)')

end % function


function hf = make_glowfig(visible)
narginchk(0,1)
if nargin < 1, visible = true; end

hf = figure('toolbar', 'none', 'name', 'aurora', 'unit', 'pixels',  'VIsible', visible);
pos = get(hf, 'position');
set(hf, 'position', [pos(1), pos(2), 800, 500])

end
%ffmpeg -framerate 10 -pattern_type glob -i '*.png' -c:v libxvid -r 30 -q:v 0 isinglass_geminiglow_4278.avi
%ffmpeg -framerate 10 -pattern_type glob -i '*.png' -c:v libx264 -r 30 -pix_fmt yuv420p out.mp4
