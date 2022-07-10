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

if isfolder(fn)
  fn = fullfile(fn, "inputs/initial_conditions.h5");
end

if isempty(file_format)
  [~, ~, suffix] = fileparts(fn);
  file_format = extractAfter(suffix, 1);
end


switch file_format
  case 'h5', write_hdf5(fn, init_cond)
  otherwise, error('gemini3d:write:state:value_error', 'unknown file_format %s', file_format)
end

end % function


function write_hdf5(fn, ics)

import stdlib.hdf5nc.h5save
import stdlib.fileio.with_suffix

fn = with_suffix(fn, ".h5");

disp("write " + fn)
if isfile(fn), delete(fn), end

freal = 'float32';

h5save(fn, '/nsall', ics.ns, "type",  freal)
h5save(fn, '/vs1all', ics.vs1, "type", freal)
h5save(fn, '/Tsall', ics.Ts, "type", freal)

if isfield(ics, 'Phitop')
  h5save(fn, '/Phiall', ics.Phitop, "type", freal)
end

if ~isfield(ics, 'time') || isempty(ics.time)
  disp("No time information was given for " + fn)
  return
end

time = ics.time;

day = [time.Year, time.Month, time.Day];
h5save(fn, '/time/ymd', day, "type", "int32")
h5save(fn, '/time/UTsec', seconds(time - datetime(day)), "type", freal)

end % function
