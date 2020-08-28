function filename = get_frame_filename(direc, time)
arguments
  direc (1,1) string
  time (1,1) datetime
end

stem0 = gemini3d.datelab(time);

direc = gemini3d.fileio.expanduser(direc);
if ~isfolder(direc)
  error('get_frame_filename:file_not_found', '%s is not a folder', direc)
end
% so that we return a usable path

suffix = [".h5", ".nc", ".dat"];

for ext = suffix
  stem = stem0;
  filename = fullfile(direc, stem + ext);
  if isfile(filename)
    break
  end
  % switch microsecond to one for first time step
  i = strlength(stem);
  stem = replaceBetween(stem, i, i, "1");
  filename = fullfile(direc, stem + ext);
  if isfile(filename)
    break
  end
end

if ~isfile(filename)
  error('get_frame_filename:file_not_found', 'could not find %s in %s', filename, direc)
end

end % function
