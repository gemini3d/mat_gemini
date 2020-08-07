function time = get_time(file)

narginchk(1,1)

time = [];  % in case not present in file
%% file handle
if isinteger(file)
  % raw file handle
  t = fread(file, 4, 'real*8');

  time = datetime(t(1), t(2), t(3)) + hours(t(4));
  return
end

%% filename
assert(ischar(file), 'must have integer file handle or filename input')

[~,~,suffix] = fileparts(file);

switch suffix
case '.h5'
  [vars, grps] = h5variables(file);

  if ~(any(contains(vars, 'ymd')) || any(contains(grps, 'time')))
    return
  end

  if contains(grps, 'time')
    i = '/time';
    vars = h5variables(file, 'time');
  else
    i = '';
  end

  d = h5read(file, [i, '/ymd']);
  time = datetime(d(1), d(2), d(3));

  if any(contains(vars, 'UTsec'))
    time = time + seconds(h5read(file, [i, '/UTsec']));
  elseif any(contains(vars, 'UThour'))
    time = time + hours(h5read(file, [i, '/UThour']));
  end

case '.nc'
  vars = ncvariables(file);

  if ~any(contains(vars, 'ymd'))
    return
  end

  d = ncread(file, 'ymd');
  time = datetime(d(1), d(2), d(3));

  if any(contains(vars, 'UTsec'))
    time = time + seconds(ncread(file, 'UTsec'));
  elseif any(contains(vars, 'UThour'))
    time = time + hours(ncread(file, 'UThour'));
  end
end %switch


end %function
