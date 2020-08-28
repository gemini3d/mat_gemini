function dat = loadframe3Dcurvavg_hdf5(filename, vars)
arguments
  filename (1,1) string
  vars (:,1) string
end
%% SIMULATIONS RESULTS
dat.filename = filename;

%% Number densities
if any(vars == "ne")
dat.ne = h5read(filename, '/neall');
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
%% Current densities
if any(vars == "J1")
dat.J1 = h5read(filename, '/J1all');
end
if any(vars == "J2")
dat.J2 = h5read(filename, '/J2all');
end
if any(vars == "J3")
dat.J3 = h5read(filename, '/J3all');
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
