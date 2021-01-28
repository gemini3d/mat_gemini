function dat = frame3Dcurv_nc4(fn, vars)
arguments
  fn (1,1) string
  vars (1,:) string
end
%% SIMULATION RESULTS

fvars = hdf5nc.ncvariables(fn);

if any(contains(vars, ["ne", "ns"]))
dat.ns = ncread(fn, "nsall");
end

for k = ["J1", "J2", "J3"]
  if any(vars == k)
  dat.(k) = ncread(fn, k + "all");
  end
end

if any(vars == "v1") && any(fvars == "vs1all")
dat.vs1 = ncread(fn, 'vs1all');
end
if any(contains(vars, ["Te", "Ti", "Ts"])) && any(fvars == "Tsall")
dat.Ts = ncread(fn, 'Tsall');
end

if any(vars == "v2") && any(fvars == "v2avgall")
dat.v2 = ncread(fn, 'v2avgall');
end
if any(vars == "v3") && any(fvars == "v3avgall")
dat.v3 = ncread(fn, 'v3avgall');
end
if any(vars == "Phitop") && any(fvars == "Phiall")
dat.Phitop = ncread(fn, 'Phiall');
end

end % function
