function dat = loadframe3Dcurv_hdf5(fn, vars)

narginchk(2,2)

%% SIMULATION RESULTS
fvars = gemini3d.fileio.h5variables(fn);

dat.filename = fn;

dat.ns = h5read(fn, '/nsall');

if any(contains(vars, 'v1'))
  dat.vs1 = h5read(fn, '/vs1all');
end

if any(contains(vars, {'Ti', 'Te'}))
  dat.Ts = h5read(fn, '/Tsall');
end

if any(contains(fvars, 'J1all'))
  if any(contains(vars, 'J1'))
  dat.J1 = squeeze(h5read(fn, '/J1all'));
  end
  if any(contains(vars, 'J2'))
  dat.J2 = squeeze(h5read(fn, '/J2all'));
  end
  if any(contains(vars, 'J3'))
  dat.J3 = squeeze(h5read(fn, '/J3all'));
  end
end

if any(contains(fvars, 'v2avgall'))
  if any(contains(vars, 'v2'))
  dat.v2 = squeeze(h5read(fn, '/v2avgall'));
  end
  if any(contains(vars, 'v3'))
  dat.v3 = squeeze(h5read(fn, '/v3avgall'));
  end
end

if any(contains(fvars, 'Phiall'))
  dat.Phitop = h5read(fn, '/Phiall');
end

end % function
