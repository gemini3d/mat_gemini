function time = get_time(file)
arguments
  file (1,1)
end

time = [];  % in case not present in file
%% file handle (.dat file)
if isnumeric(file)
  % raw file handle
  t = fread(file, 4, 'real*8');

  time = datetime(t(1), t(2), t(3)) + hours(t(4));
  return
end

%% filename
[~,~,suffix] = fileparts(file);

switch suffix
case '.h5'
  [vars, grps] = gemini3d.fileio.h5variables(file);

  if ~(any(vars == "ymd") || any(grps == "/time"))
    return
  end

  if contains(grps, 'time')
    i = "/time";
    vars = gemini3d.fileio.h5variables(file, 'time');
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

case '.nc'
  vars = gemini3d.fileio.ncvariables(file);

  if ~any(vars == "ymd")
    return
  end

  d = ncread(file, 'ymd');
  time = datetime(d(1), d(2), d(3));

  if any(vars == "UTsec")
    time = time + seconds(ncread(file, 'UTsec'));
  elseif any(vars == "UThour")
    time = time + hours(ncread(file, 'UThour'));
  end
end %switch


end %function
