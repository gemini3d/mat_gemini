function dat = loadframe3Dcurvnoelec_hdf5(filename)
%% READ IN SIMULATION DATA WITH NO ELECTRODYNAMIC PARAMS SUCH AS FROM AN INPUT FILE
narginchk(1,1)
%% SIMULATION SIZE
lxs = simsize(filename);
%% SIMULATIONS RESULTS
assert(is_file(filename), [filename,' does not exist '])
dat.filename = filename;

if isoctave
  D = load(filename);
  dat.ns = D.nsall;
  dat.vs1 = D.vs1all;
  dat.Ts = D.Tsall;
else
  dat.ns = h5read(filename, '/nsall');
  dat.vs1 = h5read(filename, '/vs1all');
  dat.Ts = h5read(filename, '/Tsall');
end

end % function
