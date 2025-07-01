function Efield(E, dir_out)
arguments
  E (1,1) struct
  dir_out (1,1) string
end

nan_check(E)

stdlib.makedir(dir_out)

write_hdf5(dir_out, E)

end


function nan_check(E)
%% this is also done in Fortran, but just to help ensure results.
for i = ["Exit", "Eyit", "Vminx1it", "Vmaxx1it", "Vminx2ist", "Vmaxx2ist", "Vminx3ist", "Vmaxx3ist"]
  mustBeFinite(E.(i))
end
end % function


function write_hdf5(dir_out, E)

import stdlib.h5save

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

freal = 'single';
% 'single' is real 32-bit floating point

h5save(fn, '/mlon', E.mlon, "size", llon, "type", freal)
h5save(fn, '/mlat', E.mlat, "size", llat, "type", freal)

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
