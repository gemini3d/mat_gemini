function dat = frame(filename, opts)

% load a single time step of plasma data from a GEMINI simulation
%
% example use
% dat = gemini3d.read.frame(filename)
% dat = gemini3d.read.frame(folder, "time", datetime)
% dat = gemini3d.read.frame(filename, "config", cfg)
% dat = gemini3d.read.frame(filename, "vars", vars)
%
% The "vars" argument allows loading a subset of variables.
% for example:
%
% gemini3d.read.frame(..., "ne")
% gemini3d.read.frame(..., ["ne", "Te"])

arguments
  filename (1,1) string
  opts.time datetime = datetime.empty
  opts.cfg struct = struct.empty
  opts.vars (1,:) string = string.empty
end

import stdlib.fileio.expanduser

filename = expanduser(filename);

if ~isfile(filename)
  if ~isempty(opts.time)
    filename = gemini3d.find.frame(filename, opts.time, "required", true);
  end
end

if isempty(opts.cfg)
  cfg = gemini3d.read.config(fileparts(filename));
else
  cfg = opts.cfg;
end

%% LOAD DIST. FILE

switch get_flagoutput(filename, cfg)
  case 1, dat = gemini3d.read.frame3Dcurv(filename, opts.vars);
  case 2, dat = gemini3d.read.frame3Dcurvavg(filename, opts.vars);
  case 3, dat = gemini3d.read.frame3Dcurvne(filename);
  otherwise, error('gemini3d:read:frame:value_error', 'Problem with flagoutput=%d. Please specify flagoutput in config file.', flagoutput)
end %switch

if ~isfield(dat, 'time')
  dat.time = gemini3d.read.time(filename);
end
if ~isfield(dat, 'filename')
  dat.filename = filename;
end
%% ensure input/simgrid matches data
% if overwrote one directory or the other, a size mismatch can result
% this is handled implicitly by xarray.Dataset in PyGemini

lxs = gemini3d.simsize(filename);
if isempty(lxs)
  % this happens for a standalone data file
  return
end

if isempty(opts.vars)
  dat_shape = size(dat.ne);
  %MZ - ne is the only variable gauranteed to be in the output files; others depend on the user selected output type...
else
  dat_shape = size(dat.(opts.vars(1)));
end

if length(dat_shape) == 2
  dat_shape(3) = 1;
end

% x1
assert(dat_shape(1) == lxs(1), 'dimension x1 length: sim_grid %d != data %d, was input/ overwritten?', dat_shape(1), lxs(1))
% x2
assert(dat_shape(2) == lxs(2), 'dimension x2 length: sim_grid %d != data %d, was input/ overwritten?', dat_shape(2), lxs(2))
% x3
assert(dat_shape(end) == lxs(3), 'dimension x3 length: sim_grid %d != data %d, was input/ overwritten?', dat_shape(3), lxs(3))

end % function


function flag = get_flagoutput(filename, cfg)
arguments
  filename (1,1) string
  cfg struct
end

import stdlib.hdf5nc.h5variables
import stdlib.hdf5nc.ncvariables

[~,~,ext] = fileparts(filename);
% regardless of what the output type is if "nsall" exists we need
% to do a full read; this is a bit messy because loadframe will check
% again below if h5 is used...
switch lower(ext)
  case '.h5', var_names = h5variables(filename);
  case '.nc', var_names = ncvariables(filename);
  case '.dat', var_names = string.empty;
  otherwise, error('gemini3d:read:frame:get_flagoutput:value_error', '%s has unknown suffix %s', filename, ext)
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
  error('gemini3d:read:frame:value_error', 'could not determine flagoutput for %s', filename)
end

end % function
