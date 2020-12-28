function maggrid(params,xmag)

arguments
    params struct
    xmag struct
end %arguments

% error checking on struct fields
assert(isfield(xmag,"R"),"R field of xmag must be defined");
assert(isfield(xmag,"THETA"),"THETA field of xmag must be defined");
assert(isfield(xmag,"PHI"),"PHI field of xmag must be defined");
assert(isfield(params,"file_format"),"file_format field of params must be defined");
assert(isfield(params,"indat_grid"),"indat_grid field of params must be defined");

% default value for gridsize
if (~isfield(xmag,"gridsize"))
    warning("maggrid --> Defaulting gridsize to flat list...")
    gridsize=[numel(R),-1,-1];
else
    gridsize=xmag.gridsize;
end %if

% write the file
switch(params.file_format)
    case "dat"
        writemagraw(params.indat_grid,xmag.R,xmag.THETA,xmag.PHI);
    otherwise
        writemagh5(params.indat_grid,xmag.R,xmag.THETA,xmag.PHI,gridsize);
end %switch

end %function


function writemagh5(filename,R,THETA,PHI,gridsize)

% hdf5 files can optionally store a gridsize variable which tells readers how to
% reshape the data into 2D or 3D arrays.

import gemini3d.fileio.with_suffix

freal = 'float32';      % default input files to real32
fn = with_suffix(filename,".h5");

hdf5nc.h5save(fn, "/lpoints",numel(R),"type",freal);
hdf5nc.h5save(fn, "/r",R(:),"type",freal);
hdf5nc.h5save(fn, "/theta",THETA(:),"type",freal);
hdf5nc.h5save(fn, "/phi",PHI(:),"type",freal);
hdf5nc.h5save(fn, "/gridsize",gridsize,"type","int32");

end %function


function writemagraw(filename,R,THETA,PHI)

% raw binary output for the magcalc program; note that this is just a flat
% list and does not carry grid size information like hdf5 does.
fn = with_suffix(filename,".dat");

fid=fopen(fn,'w');
fwrite(fid,numel(THETA),'integer*4');
fwrite(fid,R(:),'real*8');
fwrite(fid,THETA(:),'real*8');
fwrite(fid,PHI(:),'real*8');

end %function