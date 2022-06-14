function strlab = datelab(time)
% convert gemini time format to string
% microsecond resolution
arguments
  time datetime
end

day = datetime(time.Year, time.Month, time.Day, "Format", "yyyyMMdd");
UTsec = seconds(time - day);

strlab = string.empty;

for i = 1:length(day)
  strlab(i) = string(day(i)) + "_" + num2str(UTsec(i), '%012.6f');
end

end % function
