function strlab = datelab(time)
% convert gemini time format to string
% microsecond resolution
arguments
  time (1,1) datetime
end

day = datetime(time.Year, time.Month, time.Day);
UTsec = seconds(time - day);

strlab = datestr(day, "yyyymmdd") + "_" + num2str(UTsec, '%012.6f');

end % function
