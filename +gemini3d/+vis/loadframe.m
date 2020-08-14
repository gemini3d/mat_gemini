function dat = loadframe(filename, cfg, xg)
% loadframe(filename, cfg, xg)
% load a single time step of data
%
% example use
% dat = loadframe(filename)
% dat = loadframe(direc, datetime)
% dat = loadframe(filename, cfg)
% dat = loadframe(filename, cfg, xg)
import gemini3d.fileio.*
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
assert(isstruct(cfg), 'cfg must be a datetime or struct')

if nargin < 3 || isempty(xg)
  [xg, ok] = gemini3d.readgrid(fileparts(filename));
  if ~ok
    error('loadframe:value_error', 'grid did not have appropriate parameters')
  end
end
validateattributes(xg, {'struct'}, {'scalar'}, mfilename, 'grid structure', 4)

%% LOAD DIST. FILE
[~,~,ext] = fileparts(filename);
% This is messy but it was difficult to have the milestone check before
% deciding what type of file is being read...  May be a more elegant way to
% rewrite.
if strcmp(ext,'.h5')
  % regardless of what the output type is if variabl nsall exists we need
  % to do a full read; this is a bit messy because loadframe will check
  % again below if h5 is used...
  if h5exists(filename, '/nsall')
    disp('Full or milestone input detected.')
    flagoutput = 1;
  elseif isfield(cfg, 'flagoutput')
    flagoutput = cfg.flagoutput;
  elseif h5exists(filename, '/neall')
    flagoutput = 3;
  else
    flagoutput = 2;
  end

  switch flagoutput
    case 1, dat = loadframe3Dcurv(filename);
    case 2, dat = loadframe3Dcurvavg(filename);
    case 3, dat = loadframe3Dcurvne(filename);
    otherwise, error('Problem with file input selection. Please specify flagoutput in config file.')
  end %switch
else
  % currently only HDF5 supports milestones
  if isfield(cfg, 'flagoutput')
    flagoutput = cfg.flagoutput;
  elseif ncexists(cfg, 'neall')
    flagoutput = 3;
  elseif ncexists(cfg, 'Tavgall')
    flagoutput = 2;
  else
    flagoutput = 1;
  end

  switch flagoutput
    case 1, dat = loadframe3Dcurv(filename);
    case 2, dat = loadframe3Dcurvavg(filename);
    case 3, dat = loadframe3Dcurvne(filename);
    otherwise, error('Problem with file input selection. Please specify flagoutput in config file.')
  end
end

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
