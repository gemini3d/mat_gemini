function dat = loadframe(filename, cfg, vars)
% loadframe(filename, cfg, vars)
% load a single time step of data
%
% example use
% dat = loadframe(filename)
% dat = loadframe(folder, datetime)
% dat = loadframe(filename, cfg)
% dat = loadframe(filename, cfg, vars)
%
% The optional "vars" argument allows loading a subset of variables.
% for example:
%
% loadframe(..., "ne")
% loadframe(..., ["ne", "Te"])

arguments
  filename (1,1) string
  cfg = struct.empty
  vars (1,:) string = string.empty
end

if isdatetime(cfg)
  filename = gemini3d.get_frame_filename(filename, cfg);
  cfg = struct.empty;
end

%% LOAD DIST. FILE

switch get_flagoutput(filename, cfg)
  case 1, dat = gemini3d.vis.loadframe3Dcurv(filename, vars);
  case 2, dat = gemini3d.vis.loadframe3Dcurvavg(filename, vars);
  case 3, dat = gemini3d.vis.loadframe3Dcurvne(filename);
  otherwise, error('Problem with file input selection. Please specify flagoutput in config file.')
end %switch

dat.time = gemini3d.vis.get_time(filename);

%% ensure input/simgrid matches data
lxs = gemini3d.simsize(filename);
if isempty(lxs)
  % this happens for a standalone data file
  return
end
% if overwrote one directory or the other, a size mismatch can result
dat_shape = size(dat.ne);
%MZ - ne is the only variable gauranteed to be in the output files; others depend on the user selected output type...
% we check each dimension because of possibility of 2D dimension swapping
% x1

if dat_shape(1) ~= lxs(1)
  error('loadframe:value_error', 'dimension x1 length: sim_grid %d != data %d, was input/ overwritten?', dat_shape(1), lxs(1))
end
% x2
if dat_shape(2) ~= lxs(2)
  if dat_shape(2) == 1 || lxs(2) == 1
    if dat_shape(2) ~= lxs(3) % check for swap
      error('loadframe:value_error', 'dimension x2 length: sim_grid %d != data %d, was input/ overwritten?', dat_shape(2), lxs(2))
    end
  else
    error('loadframe:value_error', 'dimension x2 length: sim_grid %d != data %d, was input/ overwritten?', dat_shape(2), lxs(2))
  end
end
% x3
if lxs(3) > 1
  % squeeze() added by Matt Z. inside MatGemini can remove x3
  if dat_shape(end) ~= lxs(3)
    if dat_shape(end) == 1 || lxs(3) == 1
      if dat_shape(end) ~= lxs(2) % check for swap
        error('loadframe:value_error', 'dimension x3 length: sim_grid %d != data %d, was input/ overwritten?', dat_shape(3), lxs(3))
      end
    else
      error('loadframe:value_error', 'dimension x3 length: sim_grid %d != data %d, was input/ overwritten?', dat_shape(3), lxs(3))
    end
 end
end

end % function


function flag = get_flagoutput(filename, cfg)
arguments
  filename (1,1) string
  cfg struct
end

[~,~,ext] = fileparts(filename);
% regardless of what the output type is if "nsall" exists we need
% to do a full read; this is a bit messy because loadframe will check
% again below if h5 is used...
switch lower(ext)
  case '.h5', var_names = hdf5nc.h5variables(filename);
  case '.nc', var_names = hdf5nc.ncvariables(filename);
  case '.dat', var_names = string.empty;
  otherwise, error('loadframe:get_flagoutput:value_error', '%s has unknown suffix %s', filename, ext)
end

if any(var_names == "nsall")
  disp('Full or milestone input detected.')
  flag = 1;
elseif ~isempty(cfg) && isfield(cfg, 'flagoutput')
  flag = cfg.flagoutput;
elseif any(var_names == "Tavgall")
  flag = 2;
elseif any(var_names == "neall")
  flag = 3;
else
  error('loadframe:value_error', 'could not determine flagoutput for %s', filename)
end

end % function
