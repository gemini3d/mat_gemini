function filename = frame(direc, time, opt)
arguments
  direc (1,1) string
  time (1,1) datetime
  opt.suffix (1,:) string = [".h5", ".nc", ".dat"]
  opt.required (1,1) logical = false
end

import stdlib.fileio.expanduser

filename = string.empty;

stem0 = gemini3d.datelab(time);

direc = expanduser(direc);
% so that we return a usable path

for ext = opt.suffix
  stem = stem0;
  fn = fullfile(direc, stem + ext);
  if isfile(fn)
    filename = fn;
    return
  end
end

%% workaround: imprecise real32 filename time
% This will be removed when datetime-fortran is implemented
MAX_OFFSET = seconds(1);
%10 ms precision, allow extra accumulated tolerance

pat = datestr(time, "yyyymmdd") + "_*";
file_times = datetime.empty;
for ext = opt.suffix
    files = dir(fullfile(direc, pat + ext));
    for i = 1:length(files)
        file_times(i) = datetime(files(i).name(1:8), "InputFormat", "yyyyMMdd") + seconds(str2double(files(i).name(10:21)));
    end

    if ~isempty(file_times)
        [~, i] = min(abs(file_times - time));

        if abs(file_times(i) - time) <= MAX_OFFSET
            filename = fullfile(direc, files(i).name);
            return
        end
    end
end

if opt.required
  error("gemini33:find:frame", "did not find frame under %s", direc)
end



end % function
