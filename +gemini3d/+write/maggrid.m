function maggrid(filename,xmag)

arguments
  filename (1,1) string
  xmag (1,1) struct
end %arguments

filename = gemini3d.fileio.expanduser(filename);

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
  case ".dat", writemagraw(filename, xmag.R,xmag.THETA,xmag.PHI)
  case ".h5", writemagh5(filename, xmag.R,xmag.THETA,xmag.PHI,gridsize)
  otherwise, error(params.file_format + " not handled yet. Please open GitHub issue.")
end %switch

end %function


function writemagh5(fn,R,THETA,PHI,gridsize)

% hdf5 files can optionally store a gridsize variable which tells readers how to
% reshape the data into 2D or 3D arrays.
% NOTE: the Fortran magcalc.f90 is looking for flat list.

disp("write: " + fn)

freal = 'float32';      % default input files to real32

hdf5nc.h5save(fn, "/lpoints",numel(R),"type",freal);
hdf5nc.h5save(fn, "/r",R(:),"type",freal);
hdf5nc.h5save(fn, "/theta",THETA(:),"type",freal);
hdf5nc.h5save(fn, "/phi",PHI(:),"type",freal);
hdf5nc.h5save(fn, "/gridsize",gridsize,"type","int32");

end %function


function writemagraw(fn,R,THETA,PHI)

% raw binary output for the magcalc program; note that this is just a flat
% list and does not carry grid size information like hdf5 does.

disp("write: " + fn)

fid=fopen(fn,'w');
fwrite(fid,numel(THETA),'integer*4');
fwrite(fid,R(:),'real*8');
fwrite(fid,THETA(:),'real*8');
fwrite(fid,PHI(:),'real*8');
fclose(fid);

end %function
