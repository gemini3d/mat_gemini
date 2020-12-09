function dat = frame3Dcurvavg_hdf5(filename, vars)
arguments
  filename (1,1) string
  vars (1,:) string
end
%% SIMULATIONS RESULTS
dat.filename = filename;

for k = ["ne", "J1", "J2", "J3"]
  if any(vars == k)
  dat.(k) = h5read(filename, "/" + k + "all");
  end
end
%% Parallel Velocities
if any(vars == "v1")
dat.v1 = h5read(filename, '/v1avgall');
end
%% Temperatures
if any(vars == "Ti")
dat.Ti = h5read(filename, '/Tavgall');
end
if any(vars == "Te")
dat.Te = h5read(filename, '/TEall');
end

%% Perpendicular drifts
if any(vars == "v2")
dat.v2 = h5read(filename, '/v2avgall');
end
if any(vars == "v3")
dat.v3 = h5read(filename, '/v3avgall');
end
%% Topside potential
dat.Phitop = h5read(filename, '/Phiall');

end % function
