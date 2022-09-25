function t = time(file)
arguments
  file (1,1) string {mustBeFile}
end

t = datetime.empty;
vars = stdlib.hdf5nc.h5variables(file);

if any(vars == "ymd")

  i = "";
else
  vars = stdlib.hdf5nc.h5variables(file, "/time");
  if any(vars == "ymd")
    i = "/time";
  else
    return
  end
end


d = h5read(file, i + "/ymd");
t = datetime(d(1), d(2), d(3));

if any(vars == "UTsec")
  t = t + seconds(h5read(file, i + "/UTsec"));
elseif any(vars == "UThour")
  t = t + hours(h5read(file, i + "/UThour"));
end

end
