function dat = frame3Dcurvnoelec_nc4(filename)
%% READ IN SIMULATION DATA WITH NO ELECTRODYNAMIC PARAMS SUCH AS FROM AN INPUT FILE
arguments
  filename (1,1) string
end
%% SIMULATIONS RESULTS
dat.filename = filename;

varnames = hdf5nc.ncvariables(filename);

if any(varnames == "nsall")
  dat.ns = ncread(filename, 'nsall');
else
  dat.ns = ncread(filename, 'ns');
end

if any(varnames == "vs1all")
  dat.vs1 = ncread(filename, 'vs1all');
else
  dat.vs1 = ncread(filename, 'vsx1');
end

if any(varnames == "Tsall")
  dat.Ts = ncread(filename, 'Tsall');
else
  dat.Ts = ncread(filename, 'Ts');
end

end % function
