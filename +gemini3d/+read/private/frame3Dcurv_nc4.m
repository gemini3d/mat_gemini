function dat = frame3Dcurv_nc4(fn, vars)
arguments
  fn (1,1) string
  vars (1,:) string
end
%% SIMULATION RESULTS
dat.filename = fn;

for k = ["ne", "J1", "J2", "J3"]
  if any(vars == k)
  dat.(k) = ncread(fn, k + "all");
  end
end

if any(vars == "v1")
dat.vs1 = ncread(fn, 'vs1all');
end
if any(contains(vars, ["Te", "Ti"]))
dat.Ts = ncread(fn, 'Tsall');
end

if any(vars == "v2")
dat.v2 = ncread(fn, 'v2avgall');
end
if any(vars == "v3")
dat.v3 = ncread(fn, 'v3avgall');
end
if any(vars == "Phi")
dat.Phitop = ncread(fn, 'Phiall');
end

end % function
