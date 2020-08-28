function dat = loadframe3Dcurv_nc4(fn, vars)
arguments
  fn (1,1) string
  vars (:,1) string
end
%% SIMULATION RESULTS
dat.filename = fn;

if any(vars == "ne")
dat.ns = ncread(fn, 'nsall');
end
if any(vars == "v1")
dat.vs1 = ncread(fn, 'vs1all');
end
if any(contains(vars, ["Te", "Ti"]))
dat.Ts = ncread(fn, 'Tsall');
end
if any(vars == "J1")
dat.J1 = ncread(fn, 'J1all');
end
if any(vars == "J2")
dat.J2 = ncread(fn, 'J2all');
end
if any(vars == "J3")
dat.J3 = ncread(fn, 'J3all');
end
if any(vars == "v2")
dat.v2 = ncread(fn, 'v2avgall');
end
if any(vars == "v3")
dat.v3 = ncread(fn, 'v3avgall');
end
dat.Phitop = ncread(fn, 'Phiall');

end % function
