function write_Efield(E, dir_out, file_format)

narginchk(3,3)
validateattributes(E, {'struct'}, {'scalar'})
validateattributes(dir_out, {'char'}, {'vector'})
validateattributes(file_format, {'char'}, {'vector'})

nan_check(E)

switch file_format
  case {'h5', 'hdf5'}, write_hdf5(dir_out, E)
  case {'nc', 'nc4'},  write_nc4(dir_out, E)
  otherwise, error('write_Efield:value_error', 'unknown file format %s', file_format)
end

end


function nan_check(E)
narginchk(1,1)

%% this is also done in Fortran, but just to help ensure results.
assert(all(isfinite(E.Exit(:))), 'NaN in Exit')
assert(all(isfinite(E.Eyit(:))), 'NaN in Eyit')
assert(all(isfinite(E.Vminx1it(:))), 'NaN in Vminx1it')
assert(all(isfinite(E.Vmaxx1it(:))), 'NaN in Vmaxx1it')
assert(all(isfinite(E.Vminx2ist(:))), 'NaN in Vminx2ist')
assert(all(isfinite(E.Vmaxx2ist(:))), 'NaN in Vmaxx2ist')
assert(all(isfinite(E.Vminx3ist(:))), 'NaN in Vminx3ist')
assert(all(isfinite(E.Vmaxx3ist(:))), 'NaN in Vmaxx3ist')
end % function


function write_hdf5(dir_out, E)
narginchk(2, 2)

fn = fullfile(dir_out, 'simsize.h5');
if is_file(fn), delete(fn), end
h5save(fn, '/llon', int32(E.llon))
h5save(fn, '/llat', int32(E.llat))

llon = E.llon;
llat = E.llat;

fn = fullfile(dir_out, 'simgrid.h5');
if is_file(fn), delete(fn), end

freal = 'float32';

h5save(fn, '/mlon', E.mlon, [], freal)
h5save(fn, '/mlat', E.mlat, [], freal)

disp(['write to ', dir_out])

parfor i = 1:length(E.times)

  fn = fullfile(dir_out, [datelab(E.times(i)), '.h5']);
  if is_file(fn), delete(fn), end

  %FOR EACH FRAME WRITE A BC TYPE AND THEN OUTPUT BACKGROUND AND BCs
  h5save(fn, '/flagdirich', int32(E.flagdirich(i)))
  h5save(fn, '/Exit', E.Exit(:,:,i), [llon, llat], freal)
  h5save(fn, '/Eyit', E.Eyit(:,:,i), [llon, llat], freal)
  h5save(fn, '/Vminx1it', E.Vminx1it(:,:,i), [llon, llat], freal)
  h5save(fn, '/Vmaxx1it', E.Vmaxx1it(:,:,i), [llon, llat], freal)
  h5save(fn, '/Vminx2ist', E.Vminx2ist(:,i), llat, freal)
  h5save(fn, '/Vmaxx2ist', E.Vmaxx2ist(:,i), llat, freal)
  h5save(fn, '/Vminx3ist', E.Vminx3ist(:,i), llon, freal)
  h5save(fn, '/Vmaxx3ist', E.Vmaxx3ist(:,i), llon, freal)
end
end % function


function write_nc4(dir_out, E)
narginchk(2, 2)

fn = fullfile(dir_out, 'simsize.nc');
if is_file(fn), delete(fn), end
ncsave(fn, 'llon', int32(E.llon))
ncsave(fn, 'llat', int32(E.llat))

fn = fullfile(dir_out, 'simgrid.nc');
if is_file(fn), delete(fn), end

freal = 'float32';
dlon = {'lon', E.llon};
dlat = {'lat', E.llat};

ncsave(fn, 'mlon', E.mlon, dlon, freal)
ncsave(fn, 'mlat', E.mlat, dlat, freal)

disp(['write to ', dir_out])

parfor i = 1:length(E.times)

  fn = fullfile(dir_out, [datelab(E.times(i)), '.nc']);
  if is_file(fn), delete(fn), end

  %FOR EACH FRAME WRITE A BC TYPE AND THEN OUTPUT BACKGROUND AND BCs
  ncsave(fn, 'flagdirich', int32(E.flagdirich(i)))
  ncsave(fn, 'Exit', E.Exit(:,:,i), [dlon, dlat], freal)
  ncsave(fn, 'Eyit', E.Eyit(:,:,i), [dlon, dlat], freal)
  ncsave(fn, 'Vminx1it', E.Vminx1it(:,:,i), [dlon, dlat], freal)
  ncsave(fn, 'Vmaxx1it', E.Vmaxx1it(:,:,i), [dlon, dlat], freal)
  ncsave(fn, 'Vminx2ist', E.Vminx2ist(:,i), dlat, freal)
  ncsave(fn, 'Vmaxx2ist', E.Vmaxx2ist(:,i), dlat, freal)
  ncsave(fn, 'Vminx3ist', E.Vminx3ist(:,i), dlon, freal)
  ncsave(fn, 'Vmaxx3ist', E.Vmaxx3ist(:,i), dlon, freal)
end
end % function
