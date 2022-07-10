function maggrid(filename, xmag)

arguments
  filename (1,1) string
  xmag (1,1) struct
end

import stdlib.fileio.expanduser

filename = expanduser(filename);

% error checking on struct fields
assert(isfield(xmag,"R"),"R field of xmag must be defined");
assert(isfield(xmag,"THETA"),"THETA field of xmag must be defined");
assert(isfield(xmag,"PHI"),"PHI field of xmag must be defined");

% default value for gridsize
if ~isfield(xmag, "gridsize")
  if isvector(xmag.R)
    warning("maggrid --> Defaulting gridsize to flat list...")
    gridsize=[numel(xmag.R),-1,-1];
  else
    gridsize = size(xmag.R);
  end
else
  gridsize=xmag.gridsize;
end %if

%% write the file
[parent, ~, ext] = fileparts(filename);
assert(isfolder(parent), parent + " parent directory does not exist")

switch ext
  case ".h5", writemagh5(filename, xmag, gridsize)
  otherwise, error("gemini3d:write:maggrid:value_error", "Unknown file type %s" , filename)
end %switch

end %function


function writemagh5(fn, mag, gridsize)

import stdlib.hdf5nc.h5save

% hdf5 files can optionally store a gridsize variable which tells readers how to
% reshape the data into 2D or 3D arrays.
% NOTE: the Fortran magcalc.f90 is looking for flat list.

disp("write: " + fn)

freal = 'float32';      % default input files to real32

h5save(fn, "/lpoints",numel(mag.R), "type", "int32");
h5save(fn, "/r", mag.R(:), "type", freal);
h5save(fn, "/theta", mag.THETA(:), "type", freal);
h5save(fn, "/phi", mag.PHI(:), "type", freal);
h5save(fn, "/gridsize", gridsize, "type", "int32");

end %function
