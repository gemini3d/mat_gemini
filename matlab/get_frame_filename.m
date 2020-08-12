function filename = get_frame_filename(direc, time, UTsec)

narginchk(2,3)

if nargin < 3
  validateattributes(time, {'datetime'}, {'scalar'}, 2)
  stem0 = datelab(time);
else
  % legacy -- take time as "ymd"
  validateattributes(time, {'numeric'}, {'numel',3,'positive'}, 2)
  validateattributes(UTsec, {'numeric'}, {'scalar','nonnegative'}, 3)
  stem0 = datelab(time, UTsec);
end
direc = expanduser(direc);
if ~is_folder(direc)
  error('get_frame_filename:file_not_found', '%s is not a folder', direc)
end
% so that we return a usable path

suffix = {'.h5', '.nc', '.dat'};

for ext = suffix
  stem = stem0;
  filename = fullfile(direc, [stem, ext{1}]);
  if is_file(filename)
    break
  end
  % switch microsecond to one for first time step
  stem(end) = '1';
  filename = fullfile(direc, [stem, ext{1}]);
  if is_file(filename)
    break
  end
end

if ~is_file(filename)
  error('get_frame_filename:file_not_found', 'could not find %s in %s', filename, direc)
end


end % function
