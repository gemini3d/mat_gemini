function filename = get_frame_filename(direc, ymd, UTsec)

narginchk(3,3)
validateattributes(ymd, {'numeric'}, {'numel',3,'positive'},2)
validateattributes(UTsec, {'numeric'}, {'scalar','nonnegative'},3)

direc = expanduser(direc);
% so that we return a usable path

stem0 = datelab(ymd, UTsec);

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
