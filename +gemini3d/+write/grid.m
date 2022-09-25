function grid(p, xg)
%% write grid to file
% includes STUFF NOT NEEDED BY FORTRAN CODE BUT POSSIBLY USEFUL FOR PLOTTING
arguments
  p (1,1) struct
  xg (1,1) struct
end

%% check the input struct to make sure needed fields are present
assert(isfield(p, "indat_grid"), "gemini3d:write:grid:file_not_found", "Field indat_grid missing...");
assert(isfield(p, "indat_size"), "gemini3d:write:grid:file_not_found", "Field indat_size missing...");

%% sanity check grid
assert(gemini3d.check_grid(xg), 'gemini3d:write:grid:value_error', 'problematic grid values')

%% output directory for the simulation grids may be different
% e.g. "inputs" than the base simdir
% because grid is so important, and to catch bugs in file I/O early, let's verify the file

gdir = fileparts(p.indat_grid);
stdlib.fileio.makedir(gdir)

write_hdf5(p, xg)
[xg_check, ok] = gemini3d.read.grid(p.indat_grid);

rtol = 1e-7;  % allow for single precision
names = ["x1", "x1i", "dx1b", "dx1h", "x2", "x2i", "dx2b", "dx2h", "x3", "x3i", "dx3b", "dx3h", ...
  "h1", "h2", "h3", "h1x1i", "h2x1i", "h3x1i", "h1x2i", "h2x2i", "h3x2i", "h1x3i", "h2x3i", "h3x3i", ...
  "gx1", "gx2", "gx3", "Bmag", "I", "nullpts", "e1", "e2", "e3", "er", "etheta", "ephi", ...
  "r", "theta", "phi", "x", "y", "z"];
for n = names
  assert(gemini3d.assert_allclose(xg.(n), xg_check.(n), 'rtol', rtol, 'warnonly', true), ...
      "gemini3d:write:grid:allclose_error", "mismatch" + n)
end

if ~ok
  error('write:grid:value_error', 'values of grid are not suitable %s', p.indat_grid)
end

gemini3d.write.meta(fullfile(gdir, 'setup_grid.json'), gemini3d.git_revision(), p)

end % function


function write_hdf5(p, xg)

import stdlib.hdf5nc.h5save

%% size
fn = p.indat_size;
disp("write " + fn)
if isfile(fn), delete(fn), end

h5save(fn, '/lx1', xg.lx(1), "type", "int32")
h5save(fn, '/lx2', xg.lx(2), "type", "int32")
h5save(fn, '/lx3', xg.lx(3), "type", "int32")

lx1 = xg.lx(1);
lx2 = xg.lx(2);
lx3 = xg.lx(3);
Ng = 4;  % total number of ghost cells

%% grid
fn = p.indat_grid;
disp("write " + fn)
if isfile(fn), delete(fn), end

freal = 'float32';

h5save(fn, '/x1', xg.x1, "size", lx1 + Ng, "type", freal)
h5save(fn, '/x1i', xg.x1i, "size", lx1+1, "type", freal)
h5save(fn, '/dx1b', xg.dx1b, "size", lx1+Ng-1, "type", freal)
h5save(fn, '/dx1h', xg.dx1h, "size", lx1, "type", freal)
h5save(fn, '/x2', xg.x2, "size", lx2 + Ng, "type", freal)
h5save(fn, '/x2i', xg.x2i, "size", lx2+1, "type", freal)
h5save(fn, '/dx2b', xg.dx2b, "size", lx2+Ng-1, "type", freal)
h5save(fn, '/dx2h', xg.dx2h, "size", lx2, "type", freal)

h5save(fn, '/x3', xg.x3, "size", lx3 + Ng, "type", freal)
h5save(fn, '/x3i', xg.x3i, "size", lx3+1, "type", freal)
h5save(fn, '/dx3b', xg.dx3b, "size", lx3+Ng-1, "type", freal)
h5save(fn, '/dx3h', xg.dx3h, "size", lx3, "type", freal)

h5save(fn, '/h1', xg.h1, "size", [lx1+4, lx2+4, lx3+4], "type", freal)
h5save(fn, '/h2', xg.h2, "size", [lx1+4, lx2+4, lx3+4], "type", freal)
h5save(fn, '/h3', xg.h3, "size", [lx1+4, lx2+4, lx3+4], "type", freal)

h5save(fn, '/h1x1i', xg.h1x1i, "size", [lx1+1, lx2, lx3], "type", freal)
h5save(fn, '/h2x1i', xg.h2x1i, "size", [lx1+1, lx2, lx3], "type", freal)
h5save(fn, '/h3x1i', xg.h3x1i, "size", [lx1+1, lx2, lx3], "type", freal)

h5save(fn, '/h1x2i', xg.h1x2i, "size", [lx1, lx2+1, lx3], "type", freal)
h5save(fn, '/h2x2i', xg.h2x2i, "size", [lx1, lx2+1, lx3], "type", freal)
h5save(fn, '/h3x2i', xg.h3x2i, "size", [lx1, lx2+1, lx3], "type", freal)

h5save(fn, '/h1x3i', xg.h1x3i, "size", [lx1, lx2, lx3+1], "type", freal)
h5save(fn, '/h2x3i', xg.h2x3i, "size", [lx1, lx2, lx3+1], "type", freal)
h5save(fn, '/h3x3i', xg.h3x3i, "size", [lx1, lx2, lx3+1], "type", freal)

for i = ["gx1", "gx2", "gx3", "alt", "glat", "glon", "Bmag", "nullpts", "r", "theta","phi","x","y","z"]
  h5save(fn, "/"+i, xg.(i), "size", [lx1, lx2, lx3], "type", freal)
end

h5save(fn, '/I', xg.I, "size", [lx2, lx3], "type", freal)


for i = ["e1","e2","e3","er","etheta","ephi"]
  h5save(fn, "/"+i, xg.(i), "size", [lx1, lx2, lx3, 3], "type", freal)
end

if isfield(xg,"glonctr")
  h5save(fn,"/glonctr", xg.glonctr)
  h5save(fn,"/glatctr", xg.glatctr)
end

end % function
