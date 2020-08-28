function write_precip(pg, outdir, file_format)
%% SAVE to files
% LEAVE THE SPATIAL AND TEMPORAL INTERPOLATION TO THE
% FORTRAN CODE IN CASE DIFFERENT GRIDS NEED TO BE TRIED.
% THE EFIELD DATA DO NOT NEED TO BE SMOOTHED.
arguments
  pg (1,1) struct
  outdir (1,1) string
  file_format (1,1) string
end

disp("write to " + outdir)

switch file_format
  case 'h5', write_hdf5(outdir, pg)
  case 'nc', write_nc4(outdir, pg)
  case 'dat', write_raw(outdir, pg)
  otherwise, error('particles_BCs:value_error', 'unknown file format %s', file_format)
end

end % function


function write_hdf5(outdir, pg)
import gemini3d.fileio.h5save

fn = fullfile(outdir, 'simsize.h5');
if isfile(fn), delete(fn), end
h5save(fn, '/llon', int32(pg.llon))
h5save(fn, '/llat', int32(pg.llat))

freal = 'float32';

fn = fullfile(outdir, 'simgrid.h5');
if isfile(fn), delete(fn), end
h5save(fn, '/mlon', pg.mlon, [], freal)
h5save(fn, '/mlat', pg.mlat, [], freal)

for i = 1:length(pg.times)

  fn = fullfile(outdir, gemini3d.datelab(pg.times(i)) + ".h5");
  if isfile(fn), delete(fn), end

  h5save(fn, '/Qp', pg.Qit(:,:,i), [pg.llon, pg.llat], freal)
  h5save(fn, '/E0p', pg.E0it(:,:,i),[pg.llon, pg.llat], freal)
end

end % function


function write_nc4(outdir, pg)
import gemini3d.fileio.ncsave

fn = fullfile(outdir, 'simsize.nc');
if isfile(fn), delete(fn), end
ncsave(fn, 'llon', int32(pg.llon))
ncsave(fn, 'llat', int32(pg.llat))

freal = 'float32';

fn = fullfile(outdir, 'simgrid.nc');
if isfile(fn), delete(fn), end
ncsave(fn, 'mlon', pg.mlon, {'lon', length(pg.mlon)}, freal)
ncsave(fn, 'mlat', pg.mlat, {'lat', length(pg.mlat)}, freal)

for i = 1:length(pg.times)
  fn = fullfile(outdir, gemini3d.datelab(pg.times(i)) + ".nc");
  if isfile(fn), delete(fn), end

  ncsave(fn, 'Qp', pg.Qit(:,:,i), {'lon', length(pg.mlon), 'lat', length(pg.mlat)}, freal)
  ncsave(fn, 'E0p', pg.E0it(:,:,i), {'lon', length(pg.mlon), 'lat', length(pg.mlat)}, freal)
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
