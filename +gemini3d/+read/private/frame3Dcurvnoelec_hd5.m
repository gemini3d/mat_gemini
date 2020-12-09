function dat = frame3Dcurvnoelec_hdf5(filename)
%% READ IN SIMULATION DATA WITH NO ELECTRODYNAMIC PARAMS SUCH AS FROM AN INPUT FILE
arguments
  filename (1,1) string
end
%% SIMULATIONS RESULTS
dat.filename = filename;

varnames = hdf5nc.h5variables(filename);

if any(varnames == "nsall")
  i = '/nsall';
else
  i = '/ns';
end
dat.ns = h5read(filename, i);

if any(varnames == "vs1all")
  i = '/vs1all';
else
  i = '/vsx1';
end
dat.vs1 = h5read(filename, i);

if any(varnames == "Tsall")
  i = '/Tsall';
else
  i = '/Ts';
end
dat.Ts = h5read(filename, i);

end % function
