function dat = loadframe(direc,ymd,UTsec,flagoutput,mloc,xg, config_file, realbits)

narginchk(3,8)
validateattributes(direc, {'char'}, {'vector'}, mfilename, 'data directory', 1)
validateattributes(ymd, {'numeric'}, {'vector', 'numel', 3}, mfilename, 'year month day', 2)
validateattributes(UTsec, {'numeric'}, {'vector'}, mfilename, 'UTC second', 3)

if nargin < 8 || isempty(realbits), realbits = 64; end

if nargin < 7 || isempty(config_file)
  config_file = [direc, '/inputs'];
end

if nargin < 5 || isempty(flagoutput) || isempty(mloc)
  p = read_config(config_file);
  flagoutput = p.flagoutput;
  mloc = p.mloc;
end
validateattributes(flagoutput,{'numeric'},{'scalar'},mfilename,'output flag',4)

if ~isempty(mloc)
  validateattributes(mloc, {'numeric'}, {'vector', 'numel', 2}, mfilename, 'magnetic coordinates', 5)
end

if nargin < 6 || isempty(xg)
  xg = readgrid([direc, '/inputs'], realbits);
end
validateattributes(xg, {'struct'}, {'scalar'}, mfilename, 'grid structure', 6)


direc = absolute_path(direc);

%% LOAD DIST. FILE
stem0 = datelab(ymd, UTsec);
suffix = {'.h5', '.nc', '.dat'};
for ext = suffix
  stem = stem0;
  filename = [direc, '/', stem, ext{1}];
  if is_file(filename)
    break
  end
  % switch microsecond to one for first time step
  stem(end) = '1';
  filename = [direc, '/', stem, ext{1}];
  if is_file(filename)
    break
  end
end

if ~is_file(filename)
  error('loadframe:file_not_found %s', filename)
end

switch flagoutput
  case 1
    dat = loadframe3Dcurv(filename);
  case 2
    dat = loadframe3Dcurvavg(filename);
  otherwise
    dat = loadframe3Dcurvne(filename);
end

%% SET MAGNETIC LATITUDE AND LONGITUDE OF THE SOURCE
if ~isempty(mloc)
    dat.mlatsrc=mloc(1);
    dat.mlonsrc=mloc(2);
else
    dat.mlatsrc=[];
    dat.mlonsrc=[];
end

end % function
