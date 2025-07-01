function state(fn, init_cond)

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
end

% FIXME:  may want validate potential input

if isfolder(fn)
  fn = fullfile(fn, "inputs/initial_conditions.h5");
end

write_hdf5(fn, init_cond)

end % function


function write_hdf5(fn, ics)

import stdlib.h5save

disp("write " + fn)
if isfile(fn), delete(fn), end

freal = 'single';
% 'single' is real 32-bit floating point

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
