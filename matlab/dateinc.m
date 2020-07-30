function [ymdnew,UTsecnew]=dateinc(dt,ymd,UTsec)

narginchk(3,3)
validateattributes(dt, {'numeric'}, {'scalar', 'positive'}, mfilename, 'time step', 1)
validateattributes(ymd, {'numeric'}, {'integer', 'positive', 'numel', 3}, mfilename, 'year month day', 2)
validateattributes(UTsec, {'numeric'}, {'scalar', 'nonnegative'}, mfilename, 'UTC second', 3)

if exist('datetime', 'file')  % Matlab >= R2014b
  t0 = datetime(ymd(1), ymd(2), ymd(3));
  t1 = t0 + seconds(UTsec) + seconds(dt);

  ymdnew = [t1.Year, t1.Month, t1.Day];
  t1_midnight = datetime(t1.Year, t1.Month, t1.Day);
  UTsecnew = seconds(t1 - t1_midnight);
else
  [ymdnew, UTsecnew] = dateinc_old(dt, ymd, UTsec);
end

end % function
