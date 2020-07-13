function write_precip(pg, outdir, file_format)
%% SAVE to files
% LEAVE THE SPATIAL AND TEMPORAL INTERPOLATION TO THE
% FORTRAN CODE IN CASE DIFFERENT GRIDS NEED TO BE TRIED.
% THE EFIELD DATA DO NOT NEED TO BE SMOOTHED.

disp(['write to ',outdir])
switch file_format
  case {'h5','hdf5'}, write_hdf5(outdir, pg)
  case {'nc', 'nc4'}, write_nc4(outdir, pg)
  otherwise, error('particles_BCs:value_error', 'unknown file format %s', file_format)
end

end % function


function write_hdf5(outdir, pg)
narginchk(2,2)
fn = fullfile(outdir, 'simsize.h5');
if is_file(fn), delete(fn), end
h5save(fn, '/llon', int32(pg.llon))
h5save(fn, '/llat', int32(pg.llat))

freal = 'float32';

fn = fullfile(outdir, 'simgrid.h5');
if is_file(fn), delete(fn), end
h5save(fn, '/mlon', pg.mlon, [], freal)
h5save(fn, '/mlat', pg.mlat, [], freal)

for i = 1:size(pg.expdate, 1)
  UTsec = pg.expdate(i,4)*3600 + pg.expdate(i,5)*60 + pg.expdate(i,6);
  ymd = pg.expdate(i, 1:3);

  fn = fullfile(outdir, [datelab(ymd,UTsec), '.h5']);
  if is_file(fn), delete(fn), end

  h5save(fn, '/Qp', pg.Qit(:,:,i), [pg.llon, pg.llat], freal)
  h5save(fn, '/E0p', pg.E0it(:,:,i),[pg.llon, pg.llat], freal)
end

end % function


function write_nc4(outdir, pg)
narginchk(2,2)

fn = fullfile(outdir, 'simsize.nc');
if is_file(fn), delete(fn), end
ncsave(fn, 'llon', int32(pg.llon))
ncsave(fn, 'llat', int32(pg.llat))

freal = 'float32';

fn = fullfile(outdir, 'simgrid.nc');
if is_file(fn), delete(fn), end
ncsave(fn, 'mlon', pg.mlon, {'lon', length(pg.mlon)}, freal)
ncsave(fn, 'mlat', pg.mlat, {'lat', length(pg.mlat)}, freal)

for i = 1:size(pg.expdate, 1)
  UTsec = pg.expdate(i,4)*3600 + pg.expdate(i,5)*60 + pg.expdate(i,6);
  ymd = pg.expdate(i, 1:3);

  fn = fullfile(outdir, [datelab(ymd,UTsec), '.nc']);
  if is_file(fn), delete(fn), end

  ncsave(fn, 'Qp', pg.Qit(:,:,i), {'lon', length(pg.mlon), 'lat', length(pg.mlat)}, freal)
  ncsave(fn, 'E0p', pg.E0it(:,:,i), {'lon', length(pg.mlon), 'lat', length(pg.mlat)}, freal)
end

end % function
