function doy = day_of_year(date)
% convert date [year, month, day] to day of year

narginchk(1, 1)
validateattributes(date, {'numeric'}, {'integer', 'positive', 'numel', 3})

if exist('datetime', 'file')
  doy = day(datetime(date), 'dayofyear');
else
  doy = datenum(p.ymd(1), p.ymd(2), p.ymd(3)) - datenum(p.ymd(1),1,1) + 1;
end

end % function
