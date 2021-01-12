function Efield(E, dir_out, file_format)
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
  otherwise, error('write:Efield:value_error', 'unknown file format %s', file_format)
end

end


function nan_check(E)
%% this is also done in Fortran, but just to help ensure results.
for i = ["Exit", "Eyit", "Vminx1it", "Vmaxx1it", "Vminx2ist", "Vmaxx2ist", "Vminx3ist", "Vmaxx3ist"]
  mustBeFinite(E.(i))
end
end % function


function write_hdf5(dir_out, E)
import hdf5nc.h5save


fn = fullfile(dir_out, 'simsize.h5');
if isfile(fn), delete(fn), end
h5save(fn, '/llon', E.llon, "type", "int32")
h5save(fn, '/llat', E.llat, "type", "int32")

llon = E.llon;
llat = E.llat;

fn = fullfile(dir_out, "simgrid.h5");
if isfile(fn)
  delete(fn)
end

freal = 'float32';

h5save(fn, '/mlon', E.mlon, "type", freal)
h5save(fn, '/mlat', E.mlat, "type", freal)

disp("write to " + dir_out)

for i = 1:length(E.times)

  fn = fullfile(dir_out, gemini3d.datelab(E.times(i)) + ".h5");
  if isfile(fn), delete(fn), end

  %FOR EACH FRAME WRITE A BC TYPE AND THEN OUTPUT BACKGROUND AND BCs
  h5save(fn, '/flagdirich', E.flagdirich(i), "type", "int32")
  h5save(fn, '/Exit', E.Exit(:,:,i), "size", [llon, llat], "type", freal)
  h5save(fn, '/Eyit', E.Eyit(:,:,i), "size", [llon, llat], "type", freal)
  h5save(fn, '/Vminx1it', E.Vminx1it(:,:,i), "size", [llon, llat], "type", freal)
  h5save(fn, '/Vmaxx1it', E.Vmaxx1it(:,:,i), "size", [llon, llat], "type", freal)
  h5save(fn, '/Vminx2ist', E.Vminx2ist(:,i), "size", llat, "type", freal)
  h5save(fn, '/Vmaxx2ist', E.Vmaxx2ist(:,i), "size", llat, "type", freal)
  h5save(fn, '/Vminx3ist', E.Vminx3ist(:,i), "size", llon, "type", freal)
  h5save(fn, '/Vmaxx3ist', E.Vmaxx3ist(:,i), "size", llon, "type", freal)
end
end % function


function write_nc4(dir_out, E)
import hdf5nc.ncsave

fn = fullfile(dir_out, 'simsize.nc');
if isfile(fn), delete(fn), end
ncsave(fn, 'llon', E.llon, "type", "int32")
ncsave(fn, 'llat', E.llat, "type", "int32")

fn = fullfile(dir_out, 'simgrid.nc');
if isfile(fn), delete(fn), end

freal = 'float32';
dlon = {'lon', E.llon};
dlat = {'lat', E.llat};

ncsave(fn, 'mlon', E.mlon, "dims", dlon, "type", freal)
ncsave(fn, 'mlat', E.mlat, "dims", dlat, "type", freal)

disp("write to " + dir_out)

for i = 1:length(E.times)

  fn = fullfile(dir_out, gemini3d.datelab(E.times(i)) + ".nc");
  if isfile(fn)
    delete(fn)
  end

  %FOR EACH FRAME WRITE A BC TYPE AND THEN OUTPUT BACKGROUND AND BCs
  ncsave(fn, 'flagdirich', E.flagdirich(i), "type", "int32")
  ncsave(fn, 'Exit', E.Exit(:,:,i), "dims", [dlon, dlat], "type", freal)
  ncsave(fn, 'Eyit', E.Eyit(:,:,i), "dims", [dlon, dlat], "type", freal)
  ncsave(fn, 'Vminx1it', E.Vminx1it(:,:,i), "dims", [dlon, dlat], "type", freal)
  ncsave(fn, 'Vmaxx1it', E.Vmaxx1it(:,:,i), "dims", [dlon, dlat], "type", freal)
  ncsave(fn, 'Vminx2ist', E.Vminx2ist(:,i), "dims", dlat, "type", freal)
  ncsave(fn, 'Vmaxx2ist', E.Vmaxx2ist(:,i), "dims", dlat, "type", freal)
  ncsave(fn, 'Vminx3ist', E.Vminx3ist(:,i), "dims", dlon, "type", freal)
  ncsave(fn, 'Vmaxx3ist', E.Vmaxx3ist(:,i), "dims", dlon, "type", freal)
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
