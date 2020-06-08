function doy = day_of_year(date)
% convert date [year, month, day] to day of year

narginchk(1, 1)
validateattributes(date, {'numeric'}, {'integer', 'positive', 'numel', 3})

if exist('datetime', 'file')
  doy = day(datetime(date), 'dayofyear');
else
  doy = datenum(date(1), date(2), date(3)) - datenum(date(1),1,1) + 1;
end

end % function
