function [xg, ok] = readgrid(path, realbits)
%% READS A GRID FROM MATLAB
% OR POSSIBLY FORTRAN (THOUGH THIS IS NOT YET IMPLEMENTED AS OF 9/15/2016)
% we don't use file_format because the output / new simulation may be in
% one file format while the equilibrium sim was in another file format
narginchk(1,2)
if nargin < 2 || isempty(realbits), realbits = 64; end
validateattributes(realbits, {'numeric'}, {'scalar', 'integer'}, mfilename, '32 or 64', 2)

[path, suffix] = get_simsize_path(path);

switch suffix
  case {'.h5', '.hdf5'}, xg = read_hdf5(path);
  case '.nc', xg = read_nc4(path);
  case '.dat', xg = read_raw(path, realbits);
  otherwise, error('readgrid:value_error', 'unknown file type %s', suffix)
end

ok = check_grid(xg);
if ~ok
  warning('readgrid:value_error', '%s grid has unsuitable values', path)
end

end % function


function xgf = read_hdf5(path)

fn = fullfile(path, 'simgrid.h5');
if ~is_file(fn)
  error('readgrid:read_hdf5:file_not_found', '%s not found', fn)
end

if isoctave
  xgf = load(fn);
else
  for v = h5variables(fn)
    xgf.(v{:}) = h5read(fn, ['/',v{:}]);
  end
end

% do this last to avoid overwriting e.g. Octave
xgf.filename = fn;
xgf.lx = simsize(path);


end  % function read_hdf5


function xgf = read_nc4(path)

try %#ok<TRYNC>
  pkg load netcdf
end

fn = fullfile(path, 'simgrid.nc');
if ~is_file(fn)
  error('readgrid:read_nc4:file_not_found', '%s not found', fn)
end

for v = ncvariables(fn)
  xgf.(v{:}) = ncread(fn, v{:});
end

xgf.filename = fn;
xgf.lx = simsize(path);

end  % function read_nc4


function xgf = read_raw(path, realbits)

filename = fullfile(path, 'simgrid.dat');
if ~is_file(fileanme)
  error('readgrid:read_raw:file_not_found', '%s not found', filename)
end

xgf.lx = simsize(path);
xgf.filename = filename;

lx1=xgf.lx(1); lx2=xgf.lx(2); lx3=xgf.lx(3);
lgrid=lx1*lx2*lx3;
lgridghost=(lx1+4)*(lx2+4)*(lx3+4);
gridsize=[lx1,lx2,lx3];
gridsizeghost=[lx1+4,lx2+4,lx3+4];


%% Grid file

freal = ['float', int2str(realbits)];

fid = fopen(filename, 'r');

xgf.x1=fread(fid,lx1+4, freal);    %coordinate values
xgf.x1i=fread(fid,lx1+1, freal);
xgf.dx1b=fread(fid,lx1+3, freal);    %ZZZ - need to check that differences have appropriate ghost cell values, etc.
xgf.dx1h=fread(fid,lx1, freal);

xgf.x2=fread(fid,lx2+4, freal);
xgf.x2i=fread(fid,lx2+1, freal);
xgf.dx2b=fread(fid,lx2+3, freal);
xgf.dx2h=fread(fid,lx2, freal);

xgf.x3=fread(fid,lx3+4, freal);
xgf.x3i=fread(fid,lx3+1, freal);
xgf.dx3b=fread(fid,lx3+3, freal);
xgf.dx3h=fread(fid,lx3, freal);

tmp=fread(fid,lgridghost, freal);   %cell-centered metric coefficients
xgf.h1=reshape(tmp,gridsizeghost);
tmp=fread(fid,lgridghost, freal);
xgf.h2=reshape(tmp,gridsizeghost);
tmp=fread(fid,lgridghost, freal);
xgf.h3=reshape(tmp,gridsizeghost);

tmpsize=[lx1+1,lx2,lx3];
ltmp=prod(tmpsize);
tmp=fread(fid,ltmp, freal);    %interface metric coefficients
xgf.h1x1i=reshape(tmp,tmpsize);
tmp=fread(fid,ltmp, freal);
xgf.h2x1i=reshape(tmp,tmpsize);
tmp=fread(fid,ltmp, freal);
xgf.h3x1i=reshape(tmp,tmpsize);

tmpsize=[lx1,lx2+1,lx3];
ltmp=prod(tmpsize);
tmp=fread(fid,ltmp, freal);
xgf.h1x2i=reshape(tmp,tmpsize);
tmp=fread(fid,ltmp, freal);
xgf.h2x2i=reshape(tmp,tmpsize);
tmp=fread(fid,ltmp, freal);
xgf.h3x2i=reshape(tmp,tmpsize);

tmpsize=[lx1,lx2,lx3+1];
ltmp=prod(tmpsize);
tmp=fread(fid,ltmp, freal);
xgf.h1x3i=reshape(tmp,tmpsize);
tmp=fread(fid,ltmp, freal);
xgf.h2x3i=reshape(tmp,tmpsize);
tmp=fread(fid,ltmp, freal);
xgf.h3x3i=reshape(tmp,tmpsize);

%gravity, geographic coordinates, magnetic field strength? unit vectors?
tmp=fread(fid,lgrid, freal);    %gravitational field components
xgf.gx1=reshape(tmp,gridsize);
tmp=fread(fid,lgrid, freal);
xgf.gx2=reshape(tmp,gridsize);
tmp=fread(fid,lgrid, freal);
xgf.gx3=reshape(tmp,gridsize);

tmp=fread(fid,lgrid, freal);    %geographic coordinates
xgf.alt=reshape(tmp,gridsize);
tmp=fread(fid,lgrid, freal);
xgf.glat=reshape(tmp,gridsize);
tmp=fread(fid,lgrid, freal);
xgf.glon=reshape(tmp,gridsize);

tmp=fread(fid,lgrid, freal);    %magnetic field strength
xgf.Bmag=reshape(tmp,gridsize);

tmp=fread(fid,lx2*lx3, freal);    %magnetic field inclination - only one value for each field line
xgf.I=reshape(tmp,[lx2,lx3]);

tmp=fread(fid,lgrid, freal);    %points not to be solved
xgf.nullpts=reshape(tmp,gridsize);


%STUFF PAST THIS POINT ISN'T USED IN FORTRAN CODE BUT INCLUDED IN THE
%GRID FILE FOR COMPLETENESS
if ~feof(fid)
  tmpsize=[lx1,lx2,lx3,3];
  ltmp=prod(tmpsize);
  tmp=fread(fid,ltmp, freal);   %4D unit vectors (in cartesian components)

  if (feof(fid))    %for whatever reason, we sometimes don't hit eof until after first unit vector read...
    return;   %lazy as hell
  end

  xgf.e1=reshape(tmp,tmpsize);
  tmp=fread(fid,ltmp, freal);
  xgf.e2=reshape(tmp,tmpsize);
  tmp=fread(fid,ltmp, freal);
  xgf.e3=reshape(tmp,tmpsize);

  tmpsize=[lx1,lx2,lx3,3];
  ltmp=prod(tmpsize);
  tmp=fread(fid,ltmp, freal);
  xgf.er=reshape(tmp,tmpsize);
  tmp=fread(fid,ltmp, freal);
  xgf.etheta=reshape(tmp,tmpsize);
  tmp=fread(fid,ltmp, freal);
  xgf.ephi=reshape(tmp,tmpsize);

  tmp=fread(fid,lgrid, freal);    %spherical coordinates
  xgf.r=reshape(tmp,gridsize);
  tmp=fread(fid,lgrid, freal);
  xgf.theta=reshape(tmp,gridsize);
  tmp=fread(fid,lgrid, freal);
  xgf.phi=reshape(tmp,gridsize);

  tmp=fread(fid,lgrid, freal);     %cartesian coordinates
  xgf.x=reshape(tmp,gridsize);
  tmp=fread(fid,lgrid, freal);
  xgf.y=reshape(tmp,gridsize);
  tmp=fread(fid,lgrid, freal);
  xgf.z=reshape(tmp,gridsize);
end

fclose(fid);
end  % function read_raw
