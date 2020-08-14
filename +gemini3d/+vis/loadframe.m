function dat = loadframe(filename, cfg, xg)
% loadframe(filename, cfg, xg)
% load a single time step of data
%
% example use
% dat = loadframe(filename)
% dat = loadframe(direc, datetime)
% dat = loadframe(filename, cfg)
% dat = loadframe(filename, cfg, xg)

import gemini3d.vis.*

narginchk(1,3)
validateattributes(filename, {'char'}, {'vector'}, 1)

if nargin < 2
   cfg = struct();
end

if isdatetime(cfg)
  filename = gemini3d.get_frame_filename(filename, cfg);
  cfg = struct();
end
validateattributes(cfg, {'struct'}, {'scalar'}, mfilename, 'cfg must be a datetime or struct', 2)

if nargin < 3 || isempty(xg)
  [xg, ok] = gemini3d.readgrid(fileparts(filename));
  if ~ok
    error('loadframe:value_error', 'grid did not have appropriate parameters')
  end
end
validateattributes(xg, {'struct'}, {'scalar'}, mfilename, 'grid structure', 3)

%% LOAD DIST. FILE

switch get_flagoutput(filename, cfg)
  case 1, dat = loadframe3Dcurv(filename);
  case 2, dat = loadframe3Dcurvavg(filename);
  case 3, dat = loadframe3Dcurvne(filename);
  otherwise, error('Problem with file input selection. Please specify flagoutput in config file.')
end %switch

dat.time = get_time(filename);

%% ensure input/simgrid matches data
% if overwrote one directory or the other, a size mismatch can result
dat_shape = size(dat.ne);
%MZ - ne is the only variable gauranteed to be in the output files; others depend on the user selected output type...
% we check each dimension because of possibility of 2D dimension swapping
% x1

if dat_shape(1) ~= xg.lx(1)
  error('loadframe:value_error', 'dimension x1 length: sim_grid %d != data %d, was input/ overwritten?', dat_shape(1), xg.lx(1))
end
% x2
if dat_shape(2) ~= xg.lx(2)
  if dat_shape(2) == 1 || xg.lx(2) == 1
    if dat_shape(2) ~= xg.lx(3) % check for swap
      error('loadframe:value_error', 'dimension x2 length: sim_grid %d != data %d, was input/ overwritten?', dat_shape(2), xg.lx(2))
    end
  else
    error('loadframe:value_error', 'dimension x2 length: sim_grid %d != data %d, was input/ overwritten?', dat_shape(2), xg.lx(2))
  end
end
% x3
if xg.lx(3) > 1
  % squeeze() added by Matt Z. inside MatGemini can remove x3
  if dat_shape(end) ~= xg.lx(3)
    if dat_shape(end) == 1 || xg.lx(3) == 1
      if dat_shape(end) ~= xg.lx(2) % check for swap
        error('loadframe:value_error', 'dimension x3 length: sim_grid %d != data %d, was input/ overwritten?', dat_shape(3), xg.lx(3))
      end
    else
      error('loadframe:value_error', 'dimension x3 length: sim_grid %d != data %d, was input/ overwritten?', dat_shape(3), xg.lx(3))
    end
 end
end

end % function


function flag = get_flagoutput(filename, cfg)
narginchk(2,2)
validateattributes(filename, {'char'}, {'vector'}, 1)
validateattributes(cfg, {'struct'}, {'scalar'}, 2)

[~,~,ext] = fileparts(filename);
 % regardless of what the output type is if variabl nsall exists we need
% to do a full read; this is a bit messy because loadframe will check
% again below if h5 is used...
switch ext
  case '.h5', var_names = gemini3d.fileio.h5variables(filename);
  case '.nc', var_names = gemini3d.fileio.ncvariables(filename);
  otherwise, error('loadframe:get_flagoutput:value_error', '%s has unknown suffix %s', filename, ext)
end

if any(contains(var_names, 'nsall'))
  disp('Full or milestone input detected.')
  flag = 1;
elseif isfield(cfg, 'flagoutput')
  flag = cfg.flagoutput;
elseif any(contains(var_names, 'Tavgall'))
  flag = 2;
elseif any(contains(var_names, 'neall'))
  flag = 3;
else
  error('loadframe:value_error', 'could not determine flagoutput for %s', filename)
end

end % function
