function dat = loadframe(direc,ymd,UTsec,flagoutput,mloc,xg,config_file,realbits)


%% Error checking and setup
narginchk(3,8)
validateattributes(direc, {'char'}, {'vector'}, mfilename, 'data directory', 1)
validateattributes(ymd, {'numeric'}, {'vector', 'numel', 3}, mfilename, 'year month day', 2)
validateattributes(UTsec, {'numeric'}, {'vector'}, mfilename, 'UTC second', 3)

if nargin < 8 || isempty(realbits), realbits = 64; end

if nargin < 7 || isempty(config_file)
  config_file = direc;
end

if nargin < 4 || isempty(flagoutput)
  try
    p = read_config(config_file);
  catch excp
    if strcmp(excp.identifier, 'get_configfile:file_not_found')
      error('please specify flagoutput if not specifying config_file')
    end
    rethrow(excp)
  end
  flagoutput = p.flagoutput;
end
validateattributes(flagoutput,{'numeric'},{'scalar', 'integer'},mfilename,'output flag',4)

if nargin < 5
  mloc = [];
end
if ~isempty(mloc)
  validateattributes(mloc, {'numeric'}, {'vector', 'numel', 2}, mfilename, 'magnetic coordinates', 5)
end

if nargin < 6 || isempty(xg)
  [xg, ok] = readgrid(direc, realbits);
  if ~ok
    error('loadframe:value_error', 'grid did not have appropriate parameters')
  end
end
validateattributes(xg, {'struct'}, {'scalar'}, mfilename, 'grid structure', 6)

%% LOAD DIST. FILE
filename = get_frame_filename(direc, ymd, UTsec);

switch flagoutput
  case 1, dat = loadframe3Dcurv(filename);
  case 2,dat = loadframe3Dcurvavg(filename);
  otherwise, dat = loadframe3Dcurvne(filename);
end

%% SET MAGNETIC LATITUDE AND LONGITUDE OF THE SOURCE
if ~isempty(mloc)
    dat.mlatsrc=mloc(1);
    dat.mlonsrc=mloc(2);
else
    dat.mlatsrc=[];
    dat.mlonsrc=[];
end
%% ensure input/simgrid matches data
% if overwrote one directory or the other, a size mismatch can result
dat_shape = size(dat.ne);
dat_shape(3) = size(dat.ne, 3);  % in case of 2D dat.ne, this is how to use Matlab implicit 3d with size.
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
if dat_shape(3) ~= xg.lx(3)
  if dat_shape(3) == 1 || xg.lx(3) == 1
    if dat_shape(3) ~= xg.lx(2) % check for swap
      error('loadframe:value_error', 'dimension x3 length: sim_grid %d != data %d, was input/ overwritten?', dat_shape(3), xg.lx(3))
    end
  else
    error('loadframe:value_error', 'dimension x3 length: sim_grid %d != data %d, was input/ overwritten?', dat_shape(3), xg.lx(3))
  end
end

end % function
