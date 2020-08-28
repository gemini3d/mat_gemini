function doy = day_of_year(date)
% convert date [year, month, day] to day of year
arguments
  date (1,1) datetime
end

doy = day(date, 'dayofyear');

end % function
