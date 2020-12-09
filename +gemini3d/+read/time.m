function t = time(file)
arguments
  file (1,1)
end

t = datetime.empty;

%% file handle (.dat file)
if isnumeric(file)
  % raw file handle
  t0 = fread(file, 4, 'real*8');
  t = datetime(t0(1), t0(2), t0(3)) + hours(t0(4));
  return
end

[~, ~, suffix] = fileparts(file);

switch suffix
case '.h5', t = time_h5(file);
case '.nc', t = time_nc(file);
end %switch

end %function


function time = time_h5(file)

time = datetime.empty;
[vars, grps] = hdf5nc.h5variables(file);

if ~(any(vars == "ymd") || any(grps == "/time"))
  return
end

if any(grps == "/time")
  i = "/time";
  vars = hdf5nc.h5variables(file, '/time');
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


function time = time_nc(file)

time = datetime.empty;
vars = hdf5nc.ncvariables(file);

if any(vars == "ymd")
  time = datetime(ncread(file, 'ymd'));
else
  return
end

if any(vars == "UTsec")
  time = time + seconds(ncread(file, 'UTsec'));
elseif any(vars == "UThour")
  time = time + hours(ncread(file, 'UThour'));
end

end
