function write_Efield(E, dir_out, file_format)
arguments
  E (1,1) struct
  dir_out (1,1) string
  file_format (1,1) string
end

nan_check(E)

switch file_format
  case 'h5', write_hdf5(dir_out, E)
  case 'nc', write_nc4(dir_out, E)
  case 'dat', write_raw(dir_out, E)
  otherwise, error('write_Efield:value_error', 'unknown file format %s', file_format)
end

end


function nan_check(E)
%% this is also done in Fortran, but just to help ensure results.
for i = ["Exit", "Eyit", "Vminx1it", "Vmaxx1it", "Vminx2ist", "Vmaxx2ist", "Vminx3ist", "Vmaxx3ist"]
  mustBeFinite(E.(i))
end
end % function


function write_hdf5(dir_out, E)
import gemini3d.fileio.h5save


fn = fullfile(dir_out, 'simsize.h5');
if isfile(fn), delete(fn), end
h5save(fn, '/llon', int32(E.llon))
h5save(fn, '/llat', int32(E.llat))

llon = E.llon;
llat = E.llat;

fn = fullfile(dir_out, "simgrid.h5");
if isfile(fn)
  delete(fn)
end

freal = 'float32';

h5save(fn, '/mlon', E.mlon, [], freal)
h5save(fn, '/mlat', E.mlat, [], freal)

disp("write to " + dir_out)

for i = 1:length(E.times)

  fn = fullfile(dir_out, gemini3d.datelab(E.times(i)) + ".h5");
  if isfile(fn), delete(fn), end

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
import gemini3d.fileio.ncsave

fn = fullfile(dir_out, 'simsize.nc');
if isfile(fn), delete(fn), end
ncsave(fn, 'llon', int32(E.llon))
ncsave(fn, 'llat', int32(E.llat))

fn = fullfile(dir_out, 'simgrid.nc');
if isfile(fn), delete(fn), end

freal = 'float32';
dlon = {'lon', E.llon};
dlat = {'lat', E.llat};

ncsave(fn, 'mlon', E.mlon, dlon, freal)
ncsave(fn, 'mlat', E.mlat, dlat, freal)

disp("write to " + dir_out)

for i = 1:length(E.times)

  fn = fullfile(dir_out, gemini3d.datelab(E.times(i)) + ".nc");
  if isfile(fn)
    delete(fn)
  end

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


function write_raw(dir_out, E)

freal = 'float64';

fid = fopen(fullfile(dir_out, 'simsize.dat'), 'w');
fwrite(fid, E.llon, 'integer*4');
fwrite(fid, E.llat, 'integer*4');
fclose(fid);

fid = fopen(fullfile(dir_out, 'simgrid.dat'), 'w');
fwrite(fid, E.mlon, freal);
fwrite(fid, E.mlat, freal);
fclose(fid);

for i = 1:length(E.times)
  fid = fopen(fullfile(dir_out, gemini3d.datelab(E.times(i)) + ".dat"), 'w');

  %FOR EACH FRAME WRITE A BC TYPE AND THEN OUTPUT BACKGROUND AND BCs
%  fwrite(fid, p.flagdirich, 'int32');
  fwrite(fid, E.flagdirich(i), freal);   %FIXME - fortran code still wants this to be real...
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
