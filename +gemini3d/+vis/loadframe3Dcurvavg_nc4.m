function dat = loadframe3Dcurvavg_nc4(filename, vars)
arguments
  filename (1,1) string
  vars (:,1) string
end
%% SIMULATIONS RESULTS
dat.filename = filename;

%% Number densities
if any(vars == "ne")
dat.ne = ncread(filename, 'neall');
end
%% Parallel Velocities
if any(vars == "v1")
dat.v1 = ncread(filename, 'v1avgall');
end
%% Temperatures
if any(vars == "Ti")
dat.Ti = ncread(filename, 'Tavgall');
end
if any(vars == "Te")
dat.Te = ncread(filename, 'TEall');
end
%% Current densities
if any(vars == "J1")
dat.J1 = ncread(filename, 'J1all');
end
%  dat.J2 = permute(ncread(filename, 'J2all'), [1,3,2]);
%  dat.J3 = permute(ncread(filename, 'J3all'), [1,3,2]);
if any(vars == "J2")
dat.J2 = ncread(filename, 'J2all');
end
if any(vars == "J3")
dat.J3 = ncread(filename, 'J3all');
end
%% Perpendicular drifts
if any(vars == "v2")
dat.v2 = ncread(filename, 'v2avgall');
end
if any(vars == "v3")
dat.v3 = ncread(filename, 'v3avgall');
end
%% Topside potential
dat.Phitop = ncread(filename, 'Phiall');

end % function
