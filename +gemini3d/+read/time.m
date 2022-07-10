function t = time(file)
arguments
  file (1,1) string {mustBeNonzeroLengthText}
end

[~, ~, suffix] = fileparts(file);

switch suffix
case '.h5', t = time_h5(file);
otherwise, error('gemini3d:read:time:value_error', 'Unknown file format %s', file)
end %switch

end %function


function time = time_h5(file)

import stdlib.hdf5nc.h5variables

time = datetime.empty;
[vars, grps] = h5variables(file);

if ~(any(vars == "ymd") || any(grps == "/time"))
  return
end

if any(grps == "/time")
  i = "/time";
  vars = h5variables(file, '/time');
else
  i = "";
end

d = h5read(file, i + "/ymd");
time = datetime(d(1), d(2), d(3));

if any(vars == "UTsec")
  time = time + seconds(h5read(file, i + "/UTsec"));
elseif any(vars == "UThour")
  time = time + hours(h5read(file, i + "/UThour"));
end

end
