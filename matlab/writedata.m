function writedata(ymd, UTsec,ns,vsx1,Ts, fn, file_format, realbits, Phitop)

%% WRITE STATE VARIABLE DATA TO BE USED AS INITIAL CONDITIONS
% FOR ANOTHER SIMULATION.  NOTE THAT WE
% DO NOT HERE OUTPUT ANY OF THE ELECTRODYNAMIC
% VARIABLES SINCE THEY ARE NOT NEEDED TO START THINGS
% UP IN THE FORTRAN CODE.
%
% INPUT ARRAYS SHOULD BE TRIMMED TO THE CORRECT SIZE
% I.E. THEY SHOULD NOT INCLUDE GHOST CELLS

narginchk(7,9)
validateattributes(ymd, {'numeric'}, {'vector', 'positive', 'numel', 3}, mfilename, 'year, month, day', 1)
validateattributes(UTsec, {'numeric'}, {'scalar', 'nonnegative'}, mfilename, 'seconds since UT midnight', 2)
validateattributes(ns, {'numeric'}, {'ndims', 4,'nonnegative'}, mfilename, 'density', 3)
validateattributes(vsx1, {'numeric'}, {'ndims', 4}, mfilename, 'velocity', 4)
validateattributes(Ts, {'numeric'}, {'ndims', 4,'nonnegative'}, mfilename, 'temperature', 5)
validateattributes(fn, {'char'}, {'vector'}, mfilename, 'output filename',6)
validateattributes(file_format, {'char'}, {'vector'}, mfilename,'hdf5 or raw',7)
if nargin<=7
  realbits=64;
end
validateattributes(realbits, {'numeric'}, {'scalar','integer'},mfilename, '32 or 64',8)
if nargin<=8
    Phitop=zeros(size(ns,2),size(ns,3));
end %if
% FIXME:  may want validate potential input

switch file_format
  case 'h5', write_hdf5(fn, ymd, UTsec, ns, vsx1, Ts, Phitop)
  % Note that the raw file input does not accept potential input!!!
  case 'dat', write_raw(fn, ymd, UTsec, ns, vsx1, Ts, realbits)
  case 'nc', write_nc4(fn, ymd, UTsec, ns, vsx1, Ts, Phitop)
  otherwise, error('writedata:value_error', 'unknown file_format %s', file_format)
end

end % function


function write_hdf5(fn, ymd, UTsec, ns, vsx1, Ts, Phitop)

fn = with_suffix(fn, '.h5');

disp(['write ',fn])
if is_file(fn), delete(fn), end

h5save(fn, '/time/ymd', int32(ymd))

freal = 'float32';

h5save(fn, '/time/UTsec', UTsec, [], freal)
h5save(fn, '/nsall', ns, [], freal)
h5save(fn, '/vs1all', vsx1, [], freal)
h5save(fn, '/Tsall', Ts, [], freal)
h5save(fn, '/Phiall', Phitop, [], freal)

end % function


function write_nc4(fn, ymd, UTsec, ns, vsx1, Ts, Phitop)

if isoctave
  pkg('load','netcdf')
end

fn = with_suffix(fn, '.nc');

disp(['write ',fn])
if is_file(fn), delete(fn), end

ncsave(fn, 'ymd', int32(ymd), {'time', 3})

freal = 'float32';
dimspec = {'x1', size(ns, 1), 'x2', size(ns, 2), 'x3', size(ns,3), 'species', 7};
dimspec2 = {'x2', size(ns, 2), 'x3', size(ns,3)};

ncsave(fn, 'UTsec', UTsec)
ncsave(fn, 'nsall', ns, dimspec, freal)
ncsave(fn, 'vs1all', vsx1, dimspec, freal)
ncsave(fn, 'Tsall', Ts, dimspec, freal)
ncsave(fn, 'Phiall', Phitop, dimspec2, freal)

end % function



function write_raw(fn, ymd, UTsec, ns, vsx1, Ts, realbits)

fn = with_suffix(fn, '.dat');

disp(['write ',fn])
fid=fopen(fn, 'w');

freal = ['float',int2str(realbits)];

fwrite(fid, ymd, freal);
fwrite(fid, UTsec, freal);
fwrite(fid,ns, freal);
fwrite(fid,vsx1, freal);
fwrite(fid,Ts, freal);

fclose(fid);

end % function
