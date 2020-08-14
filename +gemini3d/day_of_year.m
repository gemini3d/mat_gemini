function doy = day_of_year(date)
% convert date [year, month, day] to day of year

narginchk(1, 1)

doy = day(datetime(date), 'dayofyear');

end % function
