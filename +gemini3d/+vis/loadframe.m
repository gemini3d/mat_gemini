function dat = loadframe(filename, cfg, vars)
% loadframe(filename, cfg, vars)
% load a single time step of data
%
% example use
% dat = loadframe(filename)
% dat = loadframe(direc, datetime)
% dat = loadframe(filename, cfg)
% dat = loadframe(filename, cfg, vars)
%
% The "vars" argument allows loading a subset of variables.
% currently only works for "ne"
arguments
  filename (1,1) string
  cfg (1,1) = struct()
  vars (:,1) string = string([])
end

if isdatetime(cfg)
  filename = gemini3d.get_frame_filename(filename, cfg);
  cfg = struct();
end

lxs = gemini3d.simsize(filename);
%% LOAD DIST. FILE

switch get_flagoutput(filename, cfg)
  case 1, dat = gemini3d.vis.loadframe3Dcurv(filename, vars);
  case 2, dat = gemini3d.vis.loadframe3Dcurvavg(filename, vars);
  case 3, dat = gemini3d.vis.loadframe3Dcurvne(filename);
  otherwise, error('Problem with file input selection. Please specify flagoutput in config file.')
end %switch

dat.time = gemini3d.vis.get_time(filename);

%% ensure input/simgrid matches data
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

[~,~,ext] = fileparts(filename);
 % regardless of what the output type is if variabl nsall exists we need
% to do a full read; this is a bit messy because loadframe will check
% again below if h5 is used...
switch ext
  case '.h5', var_names = gemini3d.fileio.h5variables(filename);
  case '.nc', var_names = gemini3d.fileio.ncvariables(filename);
  case '.dat', var_names = string([]);
  otherwise, error('loadframe:get_flagoutput:value_error', '%s has unknown suffix %s', filename, ext)
end

if any(var_names == "nsall")
  disp('Full or milestone input detected.')
  flag = 1;
elseif isfield(cfg, 'flagoutput')
  flag = cfg.flagoutput;
elseif any(var_names == "Tavgall")
  flag = 2;
elseif any(var_names == "neall")
  flag = 3;
else
  error('loadframe:value_error', 'could not determine flagoutput for %s', filename)
end

end % function
