function data(time, ns, vsx1, Ts, fn, file_format, Phitop)

%% WRITE STATE VARIABLE DATA TO BE USED AS INITIAL CONDITIONS
% FOR ANOTHER SIMULATION.  NOTE THAT WE
% DO NOT HERE OUTPUT ANY OF THE ELECTRODYNAMIC
% VARIABLES SINCE THEY ARE NOT NEEDED TO START THINGS
% UP IN THE FORTRAN CODE.
%
% INPUT ARRAYS SHOULD BE TRIMMED TO THE CORRECT SIZE
% I.E. THEY SHOULD NOT INCLUDE GHOST CELLS
arguments
  time (1,1) datetime
  ns (:,:,:,:) {mustBeFinite,mustBeNonnegative}
  vsx1 (:,:,:,:) {mustBeFinite}
  Ts (:,:,:,:) {mustBeFinite,mustBeNonnegative}
  fn (1,1) string
  file_format string = string.empty
  Phitop (:,:) {mustBeFinite} = zeros(size(ns,2),size(ns,3))
end

% FIXME:  may want validate potential input

assert(~isfolder(fn), fn + " must be a filename, not a directory")

if isempty(file_format)
  [~, ~, suffix] = fileparts(fn);
  file_format = extractAfter(suffix, 1);
end


switch file_format
  case 'h5', write_hdf5(fn, time, ns, vsx1, Ts, Phitop)
  % Note that the raw file input does not accept potential input!!!
  case 'dat', write_raw(fn, time, ns, vsx1, Ts)
  case 'nc', write_nc4(fn, time, ns, vsx1, Ts, Phitop)
  otherwise, error('writedata:value_error', 'unknown file_format %s', file_format)
end

end % function


function write_hdf5(fn, time, ns, vsx1, Ts, Phitop)
import hdf5nc.h5save

fn = gemini3d.fileio.with_suffix(fn, ".h5");

disp("write " + fn)
if isfile(fn), delete(fn), end

freal = 'float32';

day = [time.Year, time.Month, time.Day];
h5save(fn, '/time/ymd', day, "type", "int32")
h5save(fn, '/time/UTsec', seconds(time - datetime(day)), "type", freal)

h5save(fn, '/nsall', ns, "type",  freal)
h5save(fn, '/vs1all', vsx1, "type", freal)
h5save(fn, '/Tsall', Ts, "type", freal)
h5save(fn, '/Phiall', Phitop, "type", freal)

end % function


function write_nc4(fn, time, ns, vsx1, Ts, Phitop)
import hdf5nc.ncsave

fn = gemini3d.fileio.with_suffix(fn, '.nc');

disp("write " + fn)
if isfile(fn), delete(fn), end

day = [time.Year, time.Month, time.Day];
ncsave(fn, 'ymd', day, "dims", {'time', 3}, "type", "int32")
ncsave(fn, 'UTsec', seconds(time - datetime(day)))

freal = 'float32';
dimspec = {'x1', size(ns, 1), 'x2', size(ns, 2), 'x3', size(ns,3), 'species', 7};
dimspec2 = {'x2', size(ns, 2), 'x3', size(ns,3)};

ncsave(fn, 'nsall', ns, "dims", dimspec, "type", freal)
ncsave(fn, 'vs1all', vsx1, "dims", dimspec, "type", freal)
ncsave(fn, 'Tsall', Ts, "dims", dimspec, "type", freal)
ncsave(fn, 'Phiall', Phitop, "dims", dimspec2, "type", freal)

end % function



function write_raw(fn, time, ns, vsx1, Ts)

fn = gemini3d.fileio.with_suffix(fn, '.dat');

disp(['write ',fn])
fid=fopen(fn, 'w');

freal = 'float64';

ymd = [time.Year, time.Month, time.Day];
fwrite(fid, ymd, freal);
fwrite(fid, seconds(time - datetime(ymd)), freal);

fwrite(fid,ns, freal);
fwrite(fid,vsx1, freal);
fwrite(fid,Ts, freal);

fclose(fid);

end % function
