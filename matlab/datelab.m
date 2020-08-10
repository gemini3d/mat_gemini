function strlab = datelab(time, UTsec)
% convert gemini time format to string
% microsecond resolution
narginchk(1,2)

if nargin < 2
  validateattributes(time, {'datetime'}, {'scalar'},1)

  day = datetime(time.Year, time.Month, time.Day);
  UTsec = seconds(time - datetime(day));
else
  % legacy
  validateattributes(time, {'numeric'}, {'integer', 'positive', 'numel', 3}, mfilename, 'year month day', 1)
  validateattributes(UTsec, {'numeric'}, {'scalar', '>=',0,'<',86400}, mfilename, 'UTC second', 2)

  day = datetime(time(1), time(2), time(3));
end

strlab = [datestr(day, 'yyyymmdd'), '_', num2str(UTsec, '%012.6f')];

end % function
