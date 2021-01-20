function state(fn, init_cond, file_format)

%% WRITE STATE VARIABLE DATA TO BE USED AS INITIAL CONDITIONS
% FOR ANOTHER SIMULATION.  NOTE THAT WE
% DO NOT HERE OUTPUT ANY OF THE ELECTRODYNAMIC
% VARIABLES SINCE THEY ARE NOT NEEDED TO START THINGS
% UP IN THE FORTRAN CODE.
%
% INPUT ARRAYS SHOULD BE TRIMMED TO THE CORRECT SIZE
% I.E. THEY SHOULD NOT INCLUDE GHOST CELLS
arguments
  fn (1,1) string
  init_cond (1,1) struct
  file_format string = string.empty
end

% FIXME:  may want validate potential input

assert(~isfolder(fn), fn + " must be a filename, not a directory")

if isempty(file_format)
  [~, ~, suffix] = fileparts(fn);
  file_format = extractAfter(suffix, 1);
end


switch file_format
  case 'h5', write_hdf5(fn, init_cond)
  % Note that the raw file input does not accept potential input!!!
  case 'dat', write_raw(fn, init_cond)
  case 'nc', write_nc4(fn, init_cond)
  otherwise, error('writedata:value_error', 'unknown file_format %s', file_format)
end

end % function


function write_hdf5(fn, ics)
import hdf5nc.h5save

fn = gemini3d.fileio.with_suffix(fn, ".h5");

disp("write " + fn)
if isfile(fn), delete(fn), end

freal = 'float32';

time = ics.time;

day = [time.Year, time.Month, time.Day];
h5save(fn, '/time/ymd', day, "type", "int32")
h5save(fn, '/time/UTsec', seconds(time - datetime(day)), "type", freal)

h5save(fn, '/nsall', ics.ns, "type",  freal)
h5save(fn, '/vs1all', ics.vs1, "type", freal)
h5save(fn, '/Tsall', ics.Ts, "type", freal)

if isfield(ics, 'Phitop')
  h5save(fn, '/Phiall', ics.Phitop, "type", freal)
end

end % function


function write_nc4(fn, ics)
import hdf5nc.ncsave

fn = gemini3d.fileio.with_suffix(fn, '.nc');

disp("write " + fn)
if isfile(fn), delete(fn), end

time = ics.time;

day = [time.Year, time.Month, time.Day];
ncsave(fn, 'ymd', day, "dims", {'time', 3}, "type", "int32")
ncsave(fn, 'UTsec', seconds(time - datetime(day)))

freal = 'float32';
dimspec = {'x1', size(ics.ns, 1), 'x2', size(ics.ns, 2), 'x3', size(ics.ns,3), 'species', 7};
dimspec2 = {'x2', size(ics.ns, 2), 'x3', size(ics.ns,3)};

ncsave(fn, 'nsall', ics.ns, "dims", dimspec, "type", freal)
ncsave(fn, 'vs1all', ics.vs1, "dims", dimspec, "type", freal)
ncsave(fn, 'Tsall', ics.Ts, "dims", dimspec, "type", freal)

if isfield(ics, 'Phitop')
  ncsave(fn, 'Phiall', ics.Phitop, "dims", dimspec2, "type", freal)
end

end % function



function write_raw(fn,ics)

fn = gemini3d.fileio.with_suffix(fn, '.dat');

disp("write " + fn)
fid=fopen(fn, 'w');

freal = 'float64';

time = ics.time;

ymd = [time.Year, time.Month, time.Day];
fwrite(fid, ymd, freal);
fwrite(fid, seconds(time - datetime(ymd)), freal);

fwrite(fid, ics.ns, freal);
fwrite(fid, ics.vs1, freal);
fwrite(fid, ics.Ts, freal);

fclose(fid);

end % function
