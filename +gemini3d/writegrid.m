function writegrid(p, xg)
%% write grid to raw binary files
% includes STUFF NOT NEEDED BY FORTRAN CODE BUT POSSIBLY USEFUL FOR PLOTTING
arguments
  p (1,1) struct
  xg (1,1) struct
end

import gemini3d.readgrid
import gemini3d.fileio.with_suffix

%% sanity check grid
ok = gemini3d.check_grid(xg);

if ~ok
  error('writegrid:value_error', 'problematic grid values')
end

%% output directory for the simulation grids may be different
% e.g. "inputs" than the base simdir
% because grid is so important, and to catch bugs in file I/O early, let's verify the file

if isfield(p, 'file_format')
  file_format = p.file_format;
else
  [~, ~, suffix] = fileparts(p.indat_grid);
  file_format = extractAfter(suffix, 1);
end
switch file_format
  case 'h5'
    write_hdf5(p, xg)
    [xg_check, ok] = readgrid(with_suffix(p.indat_grid, '.h5'));
  case 'nc'
    write_nc4(p, xg)
    [xg_check, ok] = readgrid(with_suffix(p.indat_grid, '.nc'));
  case 'dat'
    write_raw(p, xg)
    [xg_check, ok] = readgrid(with_suffix(p.indat_grid, '.dat'));
  otherwise, error('writegrid:value_error', 'unknown file format %s', p.file_format)
end

rtol = 1e-7;  % allow for single precision
names = ["x1", "x1i", "dx1b", "dx1h", "x2", "x2i", "dx2b", "dx2h", "x3", "x3i", "dx3b", "dx3h", ...
  "h1", "h2", "h3", "h1x1i", "h2x1i", "h3x1i", "h1x2i", "h2x2i", "h3x2i", "h1x3i", "h2x3i", "h3x3i", ...
  "gx1", "gx2", "gx3", "Bmag", "I", "nullpts", "e1", "e2", "e3", "er", "etheta", "ephi", ...
  "r", "theta", "phi", "x", "y", "z"];
for n = names
  gemini3d.assert_allclose(xg.(n), xg_check.(n), rtol)
end

if ~ok
  error('writegrid:value_error', 'values of grid are not suitable %s', p.indat_grid)
end

gemini3d.log_meta_nml(gemini3d.git_revision(), fullfile(p.outdir, 'setup_meta.nml'), 'setup_matlab')

end % function


function write_hdf5(p, xg)
import gemini3d.fileio.*
%% size
fn = with_suffix(p.indat_size, '.h5');
disp("write " + fn)
if isfile(fn), delete(fn), end

h5save(fn, '/lx1', int32(xg.lx(1)))
h5save(fn, '/lx2', int32(xg.lx(2)))
h5save(fn, '/lx3', int32(xg.lx(3)))

lx1 = xg.lx(1);
lx2 = xg.lx(2);
lx3 = xg.lx(3);

%% grid
fn = with_suffix(p.indat_grid, '.h5');
disp("write " + fn)
if isfile(fn), delete(fn), end

freal = 'float32';

for i = ["x1", "x1i", "dx1b", "dx1h", "x2", "x2i", "dx2b", "dx2h"]
  h5save(fn, "/"+i, xg.(i), [], freal)
end

%MZ - squeeze() for dipole grids
for i = ["x3", "x3i", "dx3b", "dx3h"]
  h5save(fn, "/"+i, squeeze(xg.(i)), [], freal)
end

h5save(fn, '/h1', xg.h1, [lx1+4, lx2+4, lx3+4], freal)
h5save(fn, '/h2', xg.h2, [lx1+4, lx2+4, lx3+4], freal)
h5save(fn, '/h3', xg.h3, [lx1+4, lx2+4, lx3+4], freal)

h5save(fn, '/h1x1i', xg.h1x1i, [lx1+1, lx2, lx3], freal)
h5save(fn, '/h2x1i', xg.h2x1i, [lx1+1, lx2, lx3], freal)
h5save(fn, '/h3x1i', xg.h3x1i, [lx1+1, lx2, lx3], freal)

h5save(fn, '/h1x2i', xg.h1x2i, [lx1, lx2+1, lx3], freal)
h5save(fn, '/h2x2i', xg.h2x2i, [lx1, lx2+1, lx3], freal)
h5save(fn, '/h3x2i', xg.h3x2i, [lx1, lx2+1, lx3], freal)

h5save(fn, '/h1x3i', xg.h1x3i, [lx1, lx2, lx3+1], freal)
h5save(fn, '/h2x3i', xg.h2x3i, [lx1, lx2, lx3+1], freal)
h5save(fn, '/h3x3i', xg.h3x3i, [lx1, lx2, lx3+1], freal)

for i = ["gx1", "gx2", "gx3", "alt", "glat", "glon", "Bmag", "nullpts", "r", "theta","phi","x","y","z"]
  h5save(fn, "/"+i, xg.(i), [lx1, lx2, lx3], freal)
end

% MZ - squeeze() for singleton dimensions
h5save(fn, '/I', squeeze(xg.I), [lx2, lx3], freal)

for i = ["e1","e2","e3","er","etheta","ephi"]
  h5save(fn, "/"+i, xg.(i), [lx1, lx2, lx3, 3], freal)
end


%% metadata
% seems HDF5 is too buggy for strings in Matlab
% if ~verLessThan('matlab', '9.8')
%   try
%     h5save(fn, '/meta/matlab_version', version())
%     if isfield(xg, 'git')
%       h5save(fn, '/meta/git_version', xg.git.git_version)
%       h5save(fn, '/meta/git_commit', xg.git.commit)
%       h5save(fn, '/meta/git_porcelain', xg.git.porcelain)
%       h5save(fn, '/meta/git_branch', xg.git.branch)
%     end
%   catch excp
%     warning('could not write metadata to HDF5, logged same metadata to setup_meta.nml')
%   end
% end

end % function


function write_nc4(p, xg)
import gemini3d.fileio.ncsave
%% size
fn = gemini3d.fileio.with_suffix(p.indat_size, '.nc');
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
fn = gemini3d.fileio.with_suffix(p.indat_grid, '.nc');
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

ncsave(fn, 'x1', xg.x1, dimx1ghost, freal)
ncsave(fn, 'x1i', xg.x1i, dimx1i, freal)
ncsave(fn, 'dx1b', xg.dx1b, dimx1d,freal)
ncsave(fn, 'dx1h', xg.dx1h, dimx1, freal)
ncsave(fn, 'x2', xg.x2, dimx2ghost, freal)
ncsave(fn, 'x2i', xg.x2i, dimx2i, freal)
ncsave(fn, 'dx2b', xg.dx2b, dimx2d,freal)
ncsave(fn, 'dx2h', xg.dx2h, dimx2, freal)
ncsave(fn, 'x3', xg.x3, dimx3ghost, freal)
ncsave(fn, 'x3i', xg.x3i, dimx3i, freal)
ncsave(fn, 'dx3b', xg.dx3b, dimx3d,freal)
ncsave(fn, 'dx3h', xg.dx3h, dimx3, freal)

ncsave(fn, 'h1', xg.h1, [dimx1ghost, dimx2ghost, dimx3ghost], freal)
ncsave(fn, 'h2', xg.h2, [dimx1ghost, dimx2ghost, dimx3ghost], freal)
ncsave(fn, 'h3', xg.h3, [dimx1ghost, dimx2ghost, dimx3ghost], freal)

ncsave(fn, 'h1x1i', xg.h1x1i, [dimx1i, dimx2, dimx3], freal)
ncsave(fn, 'h2x1i', xg.h2x1i, [dimx1i, dimx2, dimx3], freal)
ncsave(fn, 'h3x1i', xg.h3x1i, [dimx1i, dimx2, dimx3], freal)

ncsave(fn, 'h1x2i', xg.h1x2i, [dimx1, dimx2i, dimx3], freal)
ncsave(fn, 'h2x2i', xg.h2x2i, [dimx1, dimx2i, dimx3], freal)
ncsave(fn, 'h3x2i', xg.h3x2i, [dimx1, dimx2i, dimx3], freal)

ncsave(fn, 'h1x3i', xg.h1x3i, [dimx1, dimx2, dimx3i], freal)
ncsave(fn, 'h2x3i', xg.h2x3i, [dimx1, dimx2, dimx3i], freal)
ncsave(fn, 'h3x3i', xg.h3x3i, [dimx1, dimx2, dimx3i], freal)

for i = ["gx1", "gx2", "gx3", "alt", "glat", "glon", "Bmag", "nullpts", "r", "theta","phi","x","y","z"]
  ncsave(fn, i, xg.(i), [dimx1, dimx2, dimx3], freal)
end

ncsave(fn, 'I', xg.I, [dimx2, dimx3], freal)

for i = ["e1","e2","e3","er","etheta","ephi"]
  ncsave(fn, i, xg.(i), [dimx1, dimx2, dimx3, dimecef], freal)
end

end % function


function write_raw(p, xg)
import gemini3d.fileio.with_suffix
freal = 'float64';

%% size
fn = with_suffix(p.indat_size, '.dat');
disp("write " + fn)

fid = fopen(fn, 'w');
fwrite(fid, xg.lx, 'integer*4');
fclose(fid);

%% grid
fn = with_suffix(p.indat_grid, '.h5');
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


% Copyright 2020 Michael Hirsch, Ph.D.

% Licensed under the Apache License, Version 2.0 (the "License");
% you may not use this file except in compliance with the License.
% You may obtain a copy of the License at

%     http://www.apache.org/licenses/LICENSE-2.0

% Unless required by applicable law or agreed to in writing, software
% distributed under the License is distributed on an "AS IS" BASIS,
% WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
% See the License for the specific language governing permissions and
% limitations under the License.
