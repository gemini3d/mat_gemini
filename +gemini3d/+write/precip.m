function precip(pg, outdir, file_format)
%% SAVE to files
% LEAVE THE SPATIAL AND TEMPORAL INTERPOLATION TO THE
% FORTRAN CODE IN CASE DIFFERENT GRIDS NEED TO BE TRIED.
% THE EFIELD DATA DO NOT NEED TO BE SMOOTHED.
arguments
  pg (1,1) struct
  outdir (1,1) string
  file_format (1,1) string
end

import stdlib.fileio.makedir

makedir(outdir)

disp("write precip to: " + outdir)

switch file_format
  case 'h5', write_hdf5(outdir, pg)
  case 'nc', write_nc4(outdir, pg)
  case 'dat', write_raw(outdir, pg)
  otherwise, error('write:precip:value_error', 'unknown file format %s', file_format)
end

end % function


function write_hdf5(outdir, pg)
import stdlib.hdf5nc.h5save

fn = fullfile(outdir, 'simsize.h5');
if isfile(fn), delete(fn), end
h5save(fn, '/llon', pg.llon, "type", "int32")
h5save(fn, '/llat', pg.llat, "type", "int32")

freal = 'float32';

fn = fullfile(outdir, 'simgrid.h5');
if isfile(fn), delete(fn), end
h5save(fn, '/mlon', pg.mlon, "size", pg.llon, "type", freal)
h5save(fn, '/mlat', pg.mlat, "size", pg.llat, "type", freal)

for i = 1:length(pg.times)

  fn = fullfile(outdir, gemini3d.datelab(pg.times(i)) + ".h5");
  if isfile(fn), delete(fn), end

  h5save(fn, '/Qp', pg.Qit(:,:,i), "size", [pg.llon, pg.llat], "type", freal)
  h5save(fn, '/E0p', pg.E0it(:,:,i), "size", [pg.llon, pg.llat], "type", freal)
end

end % function


function write_nc4(outdir, pg)
import stdlib.hdf5nc.ncsave

fn = fullfile(outdir, 'simsize.nc');
if isfile(fn), delete(fn), end
ncsave(fn, 'llon', pg.llon, "type", "int32")
ncsave(fn, 'llat', pg.llat, "type", "int32")

freal = 'float32';

fn = fullfile(outdir, 'simgrid.nc');
if isfile(fn), delete(fn), end
ncsave(fn, 'mlon', pg.mlon, "dims", {'lon', length(pg.mlon)}, "type", freal)
ncsave(fn, 'mlat', pg.mlat, "dims", {'lat', length(pg.mlat)}, "type", freal)

for i = 1:length(pg.times)
  fn = fullfile(outdir, gemini3d.datelab(pg.times(i)) + ".nc");
  if isfile(fn), delete(fn), end

  ncsave(fn, 'Qp', pg.Qit(:,:,i), ...
    "dims", {'lon', length(pg.mlon), 'lat', length(pg.mlat)}, "type", freal)
  ncsave(fn, 'E0p', pg.E0it(:,:,i), ...
    "dims", {'lon', length(pg.mlon), 'lat', length(pg.mlat)}, "type", freal)
end

end % function


function write_raw(outdir, pg)

filename= fullfile(outdir, 'simsize.dat');
fid=fopen(filename, 'w');
fwrite(fid, pg.llon,'integer*4');
fwrite(fid, pg.llat,'integer*4');
fclose(fid);

freal = 'float64';

filename = fullfile(outdir, 'simgrid.dat');

fid=fopen(filename,'w');
fwrite(fid, pg.mlon, freal);
fwrite(fid, pg.mlat, freal);
fclose(fid);

for i = 1:length(pg.times)
  fn = fullfile(outdir, gemini3d.datelab(pg.times(i)) + ".dat");

  fid = fopen(fn, 'w');
  fwrite(fid, pg.Qit(:,:,i), freal);
  fwrite(fid, pg.E0it(:,:,i), freal);
  fclose(fid);
end

end % function
