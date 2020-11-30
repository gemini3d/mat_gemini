% example of effect of year on grid due to Schmidt spherical harmonic
% coefficients
function grid_vs_year(opts)
arguments
  opts.outdir string = string.empty
  opts.save string = string.empty
end

if isempty(getenv('MATGEMINI'))
  run('../setup.m')
end

year = 1985:15:2020;

cfg = struct('alt_min', 80e3, 'alt_max', 1000e3, 'alt_scale', [13.75e3, 20e3, 200e3, 200e3], ...
    'Bincl', 90, 'xdist', 200e3, 'ydist', 100e3, 'lxp', 1, 'lyp', 20, ...
    'glat', 67.11, 'glon', 212.95);

for y = year
  cfg.times = datetime(y, 1, 1);

  xg = gemini3d.setup.gridgen.makegrid_cart_3D(cfg);

  if ~isempty(opts.outdir)
    cfg.outdir = opts.outdir;
    cfg.indat_size = fullfile(outdir, 'inputs/simsize.h5');
    cfg.indat_grid = fullfile(outdir, 'inputs/simgrid.h5');
    gemini3d.writegrid(cfg, xg)
  end

  gemini3d.plot_grid(xg, "geog", opts.save)
end

end
