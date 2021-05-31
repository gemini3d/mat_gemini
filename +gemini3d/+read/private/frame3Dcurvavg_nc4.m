function dat = frame3Dcurvavg_nc4(filename, vars)
arguments
  filename (1,1) string
  vars (1,:) string
end

import stdlib.hdf5nc.ncvariables

%% SIMULATIONS RESULTS
dat.filename = filename;

fvars = ncvariables(filename);

for k = ["ne", "J1", "J2", "J3"]
  if any(vars == k)
  dat.(k) = ncread(filename, k + "all");
  end
end

%% Parallel Velocities
if any(vars == "v1") && any(fvars == "v1avgall")
dat.v1 = ncread(filename, 'v1avgall');
end
%% Temperatures
if any(vars == "Ti")
dat.Ti = ncread(filename, 'Tavgall');
end
if any(vars == "Te")
dat.Te = ncread(filename, 'TEall');
end
%% Perpendicular drifts
if any(vars == "v2") && any(fvars == "v2avgall")
dat.v2 = ncread(filename, 'v2avgall');
end
if any(vars == "v3") && any(fvars == "v3avgall")
dat.v3 = ncread(filename, 'v3avgall');
end
%% Topside potential
if any(vars == "Phitop") && any(fvars == "Phiall")
dat.Phitop = ncread(filename, 'Phiall');
end

end % function
