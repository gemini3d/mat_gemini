function [xg, ok] = readgrid(apath)
%% READS A GRID FROM MATLAB
% OR POSSIBLY FORTRAN (THOUGH THIS IS NOT YET IMPLEMENTED AS OF 9/15/2016)
% we don't use file_format because the output / new simulation may be in
% one file format while the equilibrium sim was in another file format
arguments
  apath (1,1) string
end

[apath, suffix] = gemini3d.find.simsize(apath);

xg = struct.empty;
ok = false;

%% ensure HDF5/NetCDF interface is loaded
try
  hdf5nc.h5variables(string.empty);
catch e
  if any(e.identifier == ["MATLAB:undefinedVarOrClass", "MATLAB:UndefinedFunction"])
    cwd = fileparts(mfilename('fullpath'));
    run(fullfile(cwd, '../setup.m'))
  else
    rethrow(e)
  end
end
%% load
switch suffix
  case '.h5', xg = read_hdf5(apath);
  case '.nc', xg = read_nc4(apath);
  case '.dat', xg = read_raw(apath);
end

if isempty(xg)
  return
end

ok = check_grid(xg);
if ~ok
  warning('readgrid:value_error', "grid has unsuitable values: " + apath)
end

end % function


function xgf = read_hdf5(apath)

fn = fullfile(apath, 'simgrid.h5');

for v = hdf5nc.h5variables(fn)
  xgf.(v) = h5read(fn, "/" + v);
end

% do this last to avoid overwriting
xgf.filename = fn;
xgf.lx = gemini3d.simsize(apath);

end  % function read_hdf5


function xgf = read_nc4(apath)

fn = fullfile(apath, 'simgrid.nc');

for v = hdf5nc.ncvariables(fn)
  xgf.(v) = ncread(fn, v);
end

xgf.filename = fn;
xgf.lx = gemini3d.simsize(apath);

end  % function read_nc4


function xgf = read_raw(apath)

filename = fullfile(apath, 'simgrid.dat');
if ~isfile(filename)
  error('readgrid:read_raw:file_not_found', '%s not found', filename)
end

xgf.lx = gemini3d.simsize(apath);
xgf.filename = filename;

lx1=xgf.lx(1); lx2=xgf.lx(2); lx3=xgf.lx(3);
lgrid=lx1*lx2*lx3;
lgridghost=(lx1+4)*(lx2+4)*(lx3+4);
gridsize=[lx1,lx2,lx3];
gridsizeghost=[lx1+4,lx2+4,lx3+4];


%% Grid file

freal = 'float64';

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
