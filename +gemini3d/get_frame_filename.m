function filename = get_frame_filename(direc, time)
arguments
  direc (1,1) string
  time (1,1) datetime
end

filename = string.empty;

stem0 = gemini3d.datelab(time);

direc = gemini3d.fileio.expanduser(direc);
% so that we return a usable path

suffix = [".h5", ".nc", ".dat"];

for ext = suffix
  stem = stem0;
  fn = fullfile(direc, stem + ext);
  if isfile(fn)
    break
  end
  % switch microsecond to one for first time step
  i = strlength(stem);
  stem = replaceBetween(stem, i, i, "1");
  fn = fullfile(direc, stem + ext);
  if isfile(fn)
    break
  end
end

if isfile(fn)
  filename = fn;
end

end % function
