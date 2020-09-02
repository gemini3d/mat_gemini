function dat = loadframe3Dcurv_hdf5(fn, vars)
arguments
  fn (1,1) string
  vars (1,:) string
end

%% SIMULATION RESULTS
fvars = gemini3d.fileio.h5variables(fn);

dat.filename = fn;

if any(vars == "ne")
dat.ns = h5read(fn, '/nsall');
end

if any(vars == "v1")
dat.vs1 = h5read(fn, '/vs1all');
end

if any(contains(vars, ["Ti", "Te"]))
dat.Ts = h5read(fn, '/Tsall');
end

if any(fvars == "J1all")
  if any(vars == "J1")
  dat.J1 = squeeze(h5read(fn, '/J1all'));
  end
  if any(vars == "J2")
  dat.J2 = squeeze(h5read(fn, '/J2all'));
  end
  if any(vars == "J3")
  dat.J3 = squeeze(h5read(fn, '/J3all'));
  end
end

if any(fvars == "v2avgall")
  if any(vars == "v2")
  dat.v2 = squeeze(h5read(fn, '/v2avgall'));
  end
  if any(vars == "v3")
  dat.v3 = squeeze(h5read(fn, '/v3avgall'));
  end
end

if any(fvars == "Phiall")
  dat.Phitop = h5read(fn, '/Phiall');
end

end % function
