function [ymdnew,UTsecnew] = dateinc(dt, ymd, UTsec)
arguments
  dt (1,1) {mustBeNonnegative,mustBeFinite}
  ymd (3,1) {mustBeInteger,mustBePositive,mustBeFinite}
  UTsec (1,1) {mustBeNonnegative,mustBeFinite}
end

t0 = datetime(ymd(1), ymd(2), ymd(3));
t1 = t0 + seconds(UTsec) + seconds(dt);

ymdnew = [t1.Year, t1.Month, t1.Day];
t1_midnight = datetime(t1.Year, t1.Month, t1.Day);
UTsecnew = seconds(t1 - t1_midnight);

end % function
