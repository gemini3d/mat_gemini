function dat = loadframe3Dcurvnoelec_hdf5(filename)
%% READ IN SIMULATION DATA WITH NO ELECTRODYNAMIC PARAMS SUCH AS FROM AN INPUT FILE
narginchk(1,1)
%% SIMULATIONS RESULTS
dat.filename = filename;

if isoctave
  D = load(filename);
  dat.ns = D.nsall;
  dat.vs1 = D.vs1all;
  dat.Ts = D.Tsall;
  return
end

varnames = h5variables(filename);

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

end % function
