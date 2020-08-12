function dat = loadframe3Dcurv_hdf5(fn)

narginchk(1,1)
%% SIMULATION RESULTS
vars = h5variables(fn);

dat.filename = fn;

dat.ns = h5read(fn, '/nsall');
dat.vs1 = h5read(fn, '/vs1all');
dat.Ts = h5read(fn, '/Tsall');
if any(contains(vars, 'J1all'))
  dat.J1 = squeeze(h5read(fn, '/J1all'));
  dat.J2 = squeeze(h5read(fn, '/J2all'));
  dat.J3 = squeeze(h5read(fn, '/J3all'));
end
if any(contains(vars, 'v2avgall'))
  dat.v2 = squeeze(h5read(fn, '/v2avgall'));
  dat.v3 = squeeze(h5read(fn, '/v3avgall'));
end
if any(contains(vars, 'Phiall'))
  dat.Phitop = h5read(fn, '/Phiall');
end

end % function
