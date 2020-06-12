function writegrid(p, xg, outdir)
%% write grid to raw binary files
% includes STUFF NOT NEEDED BY FORTRAN CODE BUT POSSIBLY USEFUL FOR PLOTTING

narginchk(2, 3)
validateattributes(p, {'struct'}, {'scalar'}, mfilename, 'simulation parameters', 1)
validateattributes(xg, {'struct'}, {'scalar'}, mfilename, 'grid parameters', 2)

if nargin < 3
  outdir = p.outdir;
end
%% sanity check grid
ok = check_grid(xg);
if ~ok
  error('writegrid:value_error', 'problematic grid values')
end

%% output directory for the simulation grids may be different
% e.g. "inputs" than the base simdir
makedir(outdir)

xg.git = git_revision();

log_meta_nml(outdir, xg.git)

switch p.file_format
  case {'h5','hdf5'}, write_hdf5(outdir, xg)
  case {'nc', 'nc4'}, write_nc4(outdir, xg)
  case {'dat','raw'}, write_raw(outdir, xg, p.realbits)
  otherwise, error('writegrid:value_error', 'unknown file format %s', p.file_format)
end

end % function


function write_hdf5(dir_out, xg)

fn = fullfile(dir_out, 'simsize.h5');
disp(['write ',fn])
if is_file(fn), delete(fn), end
h5save(fn, '/lx1', int32(xg.lx(1)))
h5save(fn, '/lx2', int32(xg.lx(2)))
h5save(fn, '/lx3', int32(xg.lx(3)))

lx1 = xg.lx(1);
lx2 = xg.lx(2);
lx3 = xg.lx(3);

fn = fullfile(dir_out, 'simgrid.h5');
disp(['write ',fn])
if is_file(fn), delete(fn), end

freal = 'float32';

h5save(fn, '/x1', xg.x1, [], freal)
h5save(fn, '/x1i', xg.x1i, [], freal)
h5save(fn, '/dx1b', xg.dx1b, [], freal)
h5save(fn, '/dx1h', xg.dx1h, [], freal)

h5save(fn, '/x2', xg.x2, [], freal)
h5save(fn, '/x2i', xg.x2i, [], freal)
h5save(fn, '/dx2b', xg.dx2b, [], freal)
h5save(fn, '/dx2h', xg.dx2h, [], freal)

h5save(fn, '/x3', xg.x3, [], freal)
h5save(fn, '/x3i', xg.x3i, [], freal)
h5save(fn, '/dx3b', xg.dx3b, [], freal)
h5save(fn, '/dx3h', xg.dx3h, [], freal)

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

h5save(fn, '/gx1', xg.gx1, [lx1, lx2, lx3], freal)
h5save(fn, '/gx2', xg.gx2, [lx1, lx2, lx3], freal)
h5save(fn, '/gx3', xg.gx3, [lx1, lx2, lx3], freal)

h5save(fn, '/alt', xg.alt, [lx1, lx2, lx3], freal)
h5save(fn, '/glat', xg.glat, [lx1, lx2, lx3], freal)
h5save(fn, '/glon', xg.glon, [lx1, lx2, lx3], freal)

h5save(fn, '/Bmag', xg.Bmag, [lx1, lx2, lx3], freal)
h5save(fn, '/I', xg.I, [lx2, lx3], freal)
h5save(fn, '/nullpts', xg.nullpts, [lx1, lx2, lx3], freal)

h5save(fn, '/e1', xg.e1, [lx1, lx2, lx3, 3], freal)
h5save(fn, '/e2', xg.e2, [lx1, lx2, lx3, 3], freal)
h5save(fn, '/e3', xg.e3, [lx1, lx2, lx3, 3], freal)

h5save(fn, '/er', xg.er, [lx1, lx2, lx3, 3], freal)
h5save(fn, '/etheta', xg.etheta, [lx1, lx2, lx3, 3], freal)
h5save(fn, '/ephi', xg.ephi, [lx1, lx2, lx3, 3], freal)

h5save(fn, '/r', xg.r, [lx1, lx2, lx3], freal)
h5save(fn, '/theta', xg.theta, [lx1, lx2, lx3], freal)
h5save(fn, '/phi', xg.phi, [lx1, lx2, lx3], freal)

h5save(fn, '/x', xg.x, [lx1, lx2, lx3], freal)
h5save(fn, '/y', xg.y, [lx1, lx2, lx3], freal)
h5save(fn, '/z', xg.z, [lx1, lx2, lx3], freal)

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


function write_nc4(dir_out, xg)

try %#ok<TRYNC>
  pkg load netcdf
end

fn = fullfile(dir_out, 'simsize.nc');
disp(['write ',fn])
if is_file(fn), delete(fn), end

ncsave(fn, 'lx1', int32(xg.lx(1)))
ncsave(fn, 'lx2', int32(xg.lx(2)))
ncsave(fn, 'lx3', int32(xg.lx(3)))

lx1 = xg.lx(1);
lx2 = xg.lx(2);
lx3 = xg.lx(3);

fn = fullfile(dir_out, 'simgrid.nc');
disp(['write ',fn])
if is_file(fn), delete(fn), end

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

ncsave(fn, 'gx1', xg.gx1, [dimx1, dimx2, dimx3], freal)
ncsave(fn, 'gx2', xg.gx2, [dimx1, dimx2, dimx3], freal)
ncsave(fn, 'gx3', xg.gx3, [dimx1, dimx2, dimx3], freal)

ncsave(fn, 'alt', xg.alt, [dimx1, dimx2, dimx3], freal)
ncsave(fn, 'glat', xg.glat, [dimx1, dimx2, dimx3], freal)
ncsave(fn, 'glon', xg.glon, [dimx1, dimx2, dimx3], freal)

ncsave(fn, 'Bmag', xg.Bmag, [dimx1, dimx2, dimx3], freal)
ncsave(fn, 'I', xg.I, [dimx2, dimx3], freal)
ncsave(fn, 'nullpts', xg.nullpts, [dimx1, dimx2, dimx3], freal)

ncsave(fn, 'e1', xg.e1, [dimx1, dimx2, dimx3, dimecef], freal)
ncsave(fn, 'e2', xg.e2, [dimx1, dimx2, dimx3, dimecef], freal)
ncsave(fn, 'e3', xg.e3, [dimx1, dimx2, dimx3, dimecef], freal)

ncsave(fn, 'er', xg.er, [dimx1, dimx2, dimx3, dimecef], freal)
ncsave(fn, 'etheta', xg.etheta, [dimx1, dimx2, dimx3, dimecef], freal)
ncsave(fn, 'ephi', xg.ephi, [dimx1, dimx2, dimx3, dimecef], freal)

ncsave(fn, 'r', xg.r, [dimx1, dimx2, dimx3], freal)
ncsave(fn, 'theta', xg.theta, [dimx1, dimx2, dimx3], freal)
ncsave(fn, 'phi', xg.phi, [dimx1, dimx2, dimx3], freal)

ncsave(fn, 'x', xg.x, [dimx1, dimx2, dimx3], freal)
ncsave(fn, 'y', xg.y, [dimx1, dimx2, dimx3], freal)
ncsave(fn, 'z', xg.z, [dimx1, dimx2, dimx3], freal)

end % function


function write_raw(outdir, xg, realbits)

freal = ['float', int2str(realbits)];

filename = fullfile(outdir, 'simsize.dat');
disp(['write ',filename])
fid = fopen(filename, 'w');
fwrite(fid, xg.lx, 'integer*4');
fclose(fid);

fid = fopen(fullfile(outdir, 'simgrid.dat'), 'w');

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
