function write_Efield(cfg, E, dir_out)

narginchk(3,3)

nan_check(E)

switch cfg.file_format
  case {'raw', 'dat'}, write_raw(dir_out, E, cfg)
  case {'h5', 'hdf5'}, write_hdf5(dir_out, E, cfg)
  case {'nc'}, error('write_Efield:not_implemented', 'NetCDF4')
  otherwise, error('write_Efield:value_error %s', cfg.file_format)
end

end


function nan_check(E)

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


function write_hdf5(dir_out, E, p)
narginchk(3,3)

fn = [dir_out, '/simsize.h5'];
if is_file(fn), delete(fn), end
h5save(fn, '/llon', int32(E.llon))
h5save(fn, '/llat', int32(E.llat))

fn = [dir_out, '/simgrid.h5'];
if is_file(fn), delete(fn), end

freal = 'float32';

h5save(fn, '/mlon', E.mlon, [], freal)
h5save(fn, '/mlat', E.mlat, [], freal)

disp(['write to ', dir_out])
Nt = size(E.expdate, 1);
for i = 1:Nt
  UTsec = E.expdate(i, 4)*3600 + E.expdate(i,5)*60 + E.expdate(i,6);
  ymd = E.expdate(i, 1:3);

  fn = [dir_out, '/', datelab(ymd,UTsec), '.h5'];

  %FOR EACH FRAME WRITE A BC TYPE AND THEN OUTPUT BACKGROUND AND BCs
  h5save(fn, '/flagdirich', int32(p.Eflagdirich))
  h5save(fn, '/Exit', E.Exit(:,:,i), [], freal)
  h5save(fn, '/Eyit', E.Eyit(:,:,i), [], freal)
  h5save(fn, '/Vminx1it', E.Vminx1it(:,:,i), [], freal)
  h5save(fn, '/Vmaxx1it', E.Vmaxx1it(:,:,i), [], freal)
  h5save(fn, '/Vminx2ist', E.Vminx2ist(:,i), [], freal)
  h5save(fn, '/Vmaxx2ist', E.Vmaxx2ist(:,i), [], freal)
  h5save(fn, '/Vminx3ist', E.Vminx3ist(:,i), [], freal)
  h5save(fn, '/Vmaxx3ist', E.Vmaxx3ist(:,i), [], freal)
end
end % function


function write_raw(dir_out, E, p)
narginchk(3,3)

freal = ['float', int2str(p.realbits)];

fid = fopen([dir_out, '/simsize.dat'], 'w');
fwrite(fid, E.llon, 'integer*4');
fwrite(fid, E.llat, 'integer*4');
fclose(fid);

fid = fopen([dir_out, '/simgrid.dat'], 'w');
fwrite(fid, E.mlon, freal);
fwrite(fid, E.mlat, freal);
fclose(fid);

Nt = size(E.expdate, 1);
for i = 1:Nt
  UTsec = E.expdate(i,4)*3600 + E.expdate(i,5)*60 + E.expdate(i,6);
  ymd = E.expdate(i,1:3);
  filename = [dir_out, '/', datelab(ymd,UTsec), '.dat'];
  disp(['write: ',filename])
  fid = fopen(filename, 'w');

  %FOR EACH FRAME WRITE A BC TYPE AND THEN OUTPUT BACKGROUND AND BCs
%  fwrite(fid, p.flagdirich, 'int32');
  fwrite(fid, p.Eflagdirich, freal);   %FIXME - fortran code still wants this to be real...
  fwrite(fid, E.Exit(:,:,i), freal);
  fwrite(fid, E.Eyit(:,:,i), freal);
  fwrite(fid, E.Vminx1it(:,:,i), freal);
  fwrite(fid, E.Vmaxx1it(:,:,i), freal);
  fwrite(fid, E.Vminx2ist(:,i), freal);
  fwrite(fid, E.Vmaxx2ist(:,i), freal);
  fwrite(fid, E.Vminx3ist(:,i), freal);
  fwrite(fid, E.Vmaxx3ist(:,i), freal);

  fclose(fid);
end

end % function
