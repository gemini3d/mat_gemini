function grid(p, xg)
%% write grid to raw binary files
% includes STUFF NOT NEEDED BY FORTRAN CODE BUT POSSIBLY USEFUL FOR PLOTTING
arguments
  p (1,1) struct
  xg (1,1) struct
end

import stdlib.fileio.with_suffix
import stdlib.fileio.makedir

%% check the input struct to make sure needed fields are present
assert(isfield(p,"indat_grid"),"Field indat_grid missing...");
assert(isfield(p,"indat_size"),"Field indat_size missing...");

%% sanity check grid
ok = gemini3d.check_grid(xg);

if ~ok
  error('write:grid:value_error', 'problematic grid values')
end
%% output directory for the simulation grids may be different
% e.g. "inputs" than the base simdir
% because grid is so important, and to catch bugs in file I/O early, let's verify the file

[gdir, ~, suffix] = fileparts(p.indat_grid);
makedir(gdir)

if isfield(p, 'file_format')
  file_format = p.file_format;
else
  file_format = extractAfter(suffix, 1);
end
switch file_format
  case 'h5'
    write_hdf5(p, xg)
    [xg_check, ok] = gemini3d.read.grid(with_suffix(p.indat_grid, '.h5'));
  case 'nc'
    write_nc4(p, xg)
    [xg_check, ok] = gemini3d.read.grid(with_suffix(p.indat_grid, '.nc'));
  case 'dat'
    write_raw(p, xg)
    [xg_check, ok] = gemini3d.read.grid(with_suffix(p.indat_grid, '.dat'));
  otherwise, error('write:grid:value_error', 'unknown file format %s', p.file_format)
end

rtol = 1e-7;  % allow for single precision
names = ["x1", "x1i", "dx1b", "dx1h", "x2", "x2i", "dx2b", "dx2h", "x3", "x3i", "dx3b", "dx3h", ...
  "h1", "h2", "h3", "h1x1i", "h2x1i", "h3x1i", "h1x2i", "h2x2i", "h3x2i", "h1x3i", "h2x3i", "h3x3i", ...
  "gx1", "gx2", "gx3", "Bmag", "I", "nullpts", "e1", "e2", "e3", "er", "etheta", "ephi", ...
  "r", "theta", "phi", "x", "y", "z"];
for n = names
  gemini3d.assert_allclose(xg.(n), xg_check.(n), 'rtol', rtol)
end

if ~ok
  error('write:grid:value_error', 'values of grid are not suitable %s', p.indat_grid)
end

gemini3d.write.meta(fullfile(p.outdir, 'setup_grid.json'), gemini3d.git_revision(), p)

end % function


function write_hdf5(p, xg)

import stdlib.fileio.with_suffix
import stdlib.hdf5nc.h5save

%% size
fn = with_suffix(p.indat_size, '.h5');
disp("write " + fn)
if isfile(fn), delete(fn), end

h5save(fn, '/lx1', xg.lx(1), "type", "int32")
h5save(fn, '/lx2', xg.lx(2), "type", "int32")
h5save(fn, '/lx3', xg.lx(3), "type", "int32")

lx1 = xg.lx(1);
lx2 = xg.lx(2);
lx3 = xg.lx(3);

%% grid
fn = with_suffix(p.indat_grid, '.h5');
disp("write " + fn)
if isfile(fn), delete(fn), end

freal = 'float32';

for i = ["x1", "x1i", "dx1b", "dx1h", "x2", "x2i", "dx2b", "dx2h"]
  h5save(fn, "/"+i, xg.(i), "type", freal)
end

%MZ - squeeze() for dipole grids
for i = ["x3", "x3i", "dx3b", "dx3h"]
  h5save(fn, "/"+i, squeeze(xg.(i)), "type", freal)
end

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

% MZ - squeeze() for singleton dimensions
%h5save(fn, '/I', squeeze(xg.I), "size", [lx2, lx3], "type", freal)
h5save(fn, '/I', xg.I, "size", [lx2, lx3], "type", freal)


for i = ["e1","e2","e3","er","etheta","ephi"]
  h5save(fn, "/"+i, xg.(i), "size", [lx1, lx2, lx3, 3], "type", freal)
end

if isfield(xg,"glonctr")
  h5save(fn,"/glonctr",xg.glonctr)
  h5save(fn,"/glatctr",xg.glatctr)
end

end % function


function write_nc4(p, xg)

import stdlib.fileio.with_suffix
import stdlib.hdf5nc.ncsave

%% size
fn = with_suffix(p.indat_size, '.nc');
disp("write " + fn)
if isfile(fn)
  delete(fn)
end

ncsave(fn, 'lx1', int32(xg.lx(1)))
ncsave(fn, 'lx2', int32(xg.lx(2)))
ncsave(fn, 'lx3', int32(xg.lx(3)))

lx1 = xg.lx(1);
lx2 = xg.lx(2);
lx3 = xg.lx(3);

%% grid
fn = with_suffix(p.indat_grid, '.nc');
disp("write " + fn)
if isfile(fn)
  delete(fn)
end

freal = 'float32';
Ng = 4; % number of ghost cells

% matlab, octave can't have dim name and var name the same.
% this is not a problem in Python.
dimx1 = {'dimx1', lx1};
dimx2 = {'dimx2', lx2};
dimx3 = {'dimx3', lx3};
dimx1i = {'dimx1i', lx1+1};
dimx2i = {'dimx2i', lx2+1};
dimx3i = {'dimx3i', lx3+1};
dimx1d = {'dimx1d', lx1+Ng-1};
dimx2d = {'dimx2d', lx2+Ng-1};
dimx3d = {'dimx3d', lx3+Ng-1};

dimx1ghost = {'dimx1ghost', lx1 + Ng};
dimx2ghost = {'dimx2ghost', lx2 + Ng};
dimx3ghost = {'dimx3ghost', lx3 + Ng};
dimecef = {'ecef', 3};

ncsave(fn, 'x1', xg.x1, "dims", dimx1ghost, "type", freal)
ncsave(fn, 'x1i', xg.x1i, "dims", dimx1i, "type", freal)
ncsave(fn, 'dx1b', xg.dx1b, "dims", dimx1d, "type", freal)
ncsave(fn, 'dx1h', xg.dx1h, "dims", dimx1, "type", freal)
ncsave(fn, 'x2', xg.x2, "dims", dimx2ghost, "type", freal)
ncsave(fn, 'x2i', xg.x2i, "dims", dimx2i, "type", freal)
ncsave(fn, 'dx2b', xg.dx2b, "dims", dimx2d, "type", freal)
ncsave(fn, 'dx2h', xg.dx2h, "dims", dimx2, "type", freal)
ncsave(fn, 'x3', xg.x3, "dims", dimx3ghost, "type", freal)
ncsave(fn, 'x3i', xg.x3i, "dims", dimx3i, "type", freal)
ncsave(fn, 'dx3b', xg.dx3b, "dims", dimx3d, "type", freal)
ncsave(fn, 'dx3h', xg.dx3h, "dims", dimx3, "type", freal)

ncsave(fn, 'h1', xg.h1, "dims", [dimx1ghost, dimx2ghost, dimx3ghost], "type", freal)
ncsave(fn, 'h2', xg.h2, "dims", [dimx1ghost, dimx2ghost, dimx3ghost], "type", freal)
ncsave(fn, 'h3', xg.h3, "dims", [dimx1ghost, dimx2ghost, dimx3ghost], "type", freal)

ncsave(fn, 'h1x1i', xg.h1x1i, "dims", [dimx1i, dimx2, dimx3], "type", freal)
ncsave(fn, 'h2x1i', xg.h2x1i, "dims", [dimx1i, dimx2, dimx3], "type", freal)
ncsave(fn, 'h3x1i', xg.h3x1i, "dims", [dimx1i, dimx2, dimx3], "type", freal)

ncsave(fn, 'h1x2i', xg.h1x2i, "dims", [dimx1, dimx2i, dimx3], "type", freal)
ncsave(fn, 'h2x2i', xg.h2x2i, "dims", [dimx1, dimx2i, dimx3], "type", freal)
ncsave(fn, 'h3x2i', xg.h3x2i, "dims", [dimx1, dimx2i, dimx3], "type", freal)

ncsave(fn, 'h1x3i', xg.h1x3i, "dims", [dimx1, dimx2, dimx3i], "type", freal)
ncsave(fn, 'h2x3i', xg.h2x3i, "dims", [dimx1, dimx2, dimx3i], "type", freal)
ncsave(fn, 'h3x3i', xg.h3x3i, "dims", [dimx1, dimx2, dimx3i], "type", freal)

for i = ["gx1", "gx2", "gx3", "alt", "glat", "glon", "Bmag", "nullpts", "r", "theta","phi","x","y","z"]
  ncsave(fn, i, xg.(i), "dims", [dimx1, dimx2, dimx3], "type", freal)
end

ncsave(fn, 'I', xg.I, "dims", [dimx2, dimx3], "type", freal)

for i = ["e1","e2","e3","er","etheta","ephi"]
  ncsave(fn, i, xg.(i), "dims", [dimx1, dimx2, dimx3, dimecef], "type", freal)
end

if isfield(xg,"glonctr")
  ncsave(fn, "glonctr", xg.glonctr)
  ncsave(fn, "glatctr", xg.glatctr)
end

end % function


function write_raw(p, xg)
import stdlib.fileio.with_suffix
freal = 'float64';

%% size
fn = with_suffix(p.indat_size, '.dat');
disp("write " + fn)

fid = fopen(fn, 'w');
fwrite(fid, xg.lx, 'integer*4');
fclose(fid);

%% grid
fn = with_suffix(p.indat_grid, '.dat');
disp("write " + fn)

fid = fopen(fn, 'w');

fwrite(fid,xg.x1, freal);    %coordinate values
fwrite(fid,xg.x1i, freal);
fwrite(fid,xg.dx1b, freal);
fwrite(fid,xg.dx1h, freal);

fwrite(fid,xg.x2, freal);
fwrite(fid,xg.x2i, freal);
fwrite(fid,xg.dx2b, freal);
fwrite(fid,xg.dx2h, freal);

fwrite(fid,xg.x3, freal);
fwrite(fid,xg.x3i, freal);
fwrite(fid,xg.dx3b, freal);
fwrite(fid,xg.dx3h, freal);

fwrite(fid,xg.h1, freal);   %cell-centered metric coefficients
fwrite(fid,xg.h2, freal);
fwrite(fid,xg.h3, freal);

fwrite(fid,xg.h1x1i, freal);    %interface metric coefficients
fwrite(fid,xg.h2x1i, freal);
fwrite(fid,xg.h3x1i, freal);

fwrite(fid,xg.h1x2i, freal);
fwrite(fid,xg.h2x2i, freal);
fwrite(fid,xg.h3x2i, freal);

fwrite(fid,xg.h1x3i, freal);
fwrite(fid,xg.h2x3i, freal);
fwrite(fid,xg.h3x3i, freal);

%gravity, geographic coordinates, magnetic field strength? unit vectors?
fwrite(fid,xg.gx1, freal);    %gravitational field components
fwrite(fid,xg.gx2, freal);
fwrite(fid,xg.gx3, freal);

fwrite(fid,xg.alt, freal);    %geographic coordinates
fwrite(fid,xg.glat, freal);
fwrite(fid,xg.glon, freal);

fwrite(fid,xg.Bmag, freal);    %magnetic field strength

fwrite(fid,xg.I, freal);    %magnetic field inclination

fwrite(fid,xg.nullpts, freal);    %points not to be solved


%NOT ALL OF THE REMAIN INFO IS USED IN THE FORTRAN CODE, BUT IT INCLUDED FOR COMPLETENESS
fwrite(fid,xg.e1, freal);   %4D unit vectors (in cartesian components)
fwrite(fid,xg.e2, freal);
fwrite(fid,xg.e3, freal);

fwrite(fid,xg.er, freal);    %spherical unit vectors
fwrite(fid,xg.etheta, freal);
fwrite(fid,xg.ephi, freal);

fwrite(fid,xg.r, freal);    %spherical coordinates
fwrite(fid,xg.theta, freal);
fwrite(fid,xg.phi, freal);

fwrite(fid,xg.x, freal);     %cartesian coordinates
fwrite(fid,xg.y, freal);
fwrite(fid,xg.z, freal);

fclose(fid);

end
