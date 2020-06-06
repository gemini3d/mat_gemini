function dat = loadframe3Dcurvnoelec_hdf5(filename)
%% READ IN SIMULATION DATA WITH NO ELECTRODYNAMIC PARAMS SUCH AS FROM AN INPUT FILE
narginchk(1,1)
%% SIMULATIONS RESULTS
assert(is_file(filename), [filename,' does not exist '])
dat.filename = filename;

if isoctave
  D = load(filename);
  %dat.simdate(1:3) = D.time.ymd;
  %dat.simdate(4) = D.time.UThour;
  dat.ns = D.nsall;
  dat.vs1 = D.vs1all;
  dat.Ts = D.Tsall;
else

  [varnames, grpnames] = h5variables(filename);

  if any(strcmp('time', grpnames))
    i = '/time';
  else
    i = '';
  end

  dat.simdate(1:3) = double(h5read(filename, [i, '/ymd']));

  try
    dat.simdate(4) = h5read(filename, [i, '/UThour']);
  catch
    dat.simdate(4) = h5read(filename, [i, '/UTsec']) / 3600;
  if any(strcmp('nsall', varnames))
    i = '/nsall';
  else
    i = '/ns';
  end
  dat.ns = h5read(filename, i);

  if any(strcmp('vs1all', varnames))
    i = '/vs1all';
  else
    i = '/vsx1';
  end
  dat.vs1 = h5read(filename, i);

  if any(strcmp('Tsall', varnames))
    i = '/Tsall';
  else
    i = '/Ts';
  end
  dat.Ts = h5read(filename, i);

end

end % function
