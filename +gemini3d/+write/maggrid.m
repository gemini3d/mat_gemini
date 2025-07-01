function maggrid(file, mag)
% write magnetic grid to HDF5 file for reading by Gemini3D "magcalc" program
% typically called by gemini3d.model.magcalc()
arguments
  file (1,1) string
  mag (1,1) struct
end

import stdlib.h5save

% error checking on struct fields
for n = ["R", "THETA", "PHI"]
  assert(isfield(mag, n), n + " field of xmag is not defined")
end

% default value for gridsize
if ~isfield(mag, "gridsize")
  if isvector(mag.R)
    warning("maggrid --> Defaulting gridsize to flat list...")
    gridsize=[numel(mag.R),-1,-1];
  else
    gridsize = size(mag.R);
  end
else
  gridsize=mag.gridsize;
end %if

%% write the file
% hdf5 files can optionally store a gridsize variable which tells readers how to
% reshape the data into 2D or 3D arrays.
% NOTE: the Fortran magcalc.f90 is looking for flat list.

file = stdlib.expanduser(file);
disp("write: " + file)

freal = 'single';
% 'single' is real 32-bit floating point

h5save(file, "/lpoints", numel(mag.R), type="int32");
h5save(file, "/r", mag.R(:), type=freal);
h5save(file, "/theta", mag.THETA(:), type=freal);
h5save(file, "/phi", mag.PHI(:), type=freal);
h5save(file, "/gridsize", gridsize, type="int32");

end %function
