function filename = frame(direc, time, suffix)
arguments
  direc (1,1) string {mustBeNonzeroLengthText}
  time (1,1) datetime
  suffix (1,1) string {mustBeNonzeroLengthText} = ".h5"
end

gemini3d.sys.check_stdlib()

filename = string.empty;

stem0 = gemini3d.datelab(time);

direc = stdlib.expanduser(direc);
% so that we return a usable path

stem = stem0;
fn = fullfile(direc, stem + suffix);
if isfile(fn)
  filename = fn;
  return
end

%% workaround: imprecise real32 filename time
% This will be removed when datetime-fortran is implemented
MAX_OFFSET = seconds(1);
%10 ms precision, allow extra accumulated tolerance

time = datetime(time, "Format", "yyyyMMdd");
pat = string(time) + "_*";
file_times = datetime.empty;
files = dir(fullfile(direc, pat + suffix));
for i = 1:length(files)
  file_times(i) = datetime(files(i).name(1:8), "InputFormat", "yyyyMMdd") + seconds(str2double(files(i).name(10:21)));
end

if ~isempty(file_times)
  [~, i] = min(abs(file_times - time));

  if abs(file_times(i) - time) <= MAX_OFFSET
    n = fullfile(direc, files(i).name);
    if(isfile(n))
      filename = n;
    end
  end
end

end % function
