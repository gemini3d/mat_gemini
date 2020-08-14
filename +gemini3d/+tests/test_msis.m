%% MSIS setup
cfg = struct('times', datetime(2015, 1, 2) + seconds(43200),...
  'f107', 100.0, 'f107a', 100.0, 'Ap', 4);
lx = [4, 2, 3];
[glon, alt, glat] = meshgrid(linspace(-147, -145, lx(2)), linspace(100e3, 200e3, lx(1)), linspace(65, 66, lx(3)));
xg = struct('glat', glat, 'glon', glon, 'lx', lx, 'alt', alt);
atmos = gemini3d.setup.msis_matlab3D(cfg, xg);
assert(all(size(atmos) == [lx(1), lx(2), lx(3), 7]), 'MSIS setup data output shape unexpected')
