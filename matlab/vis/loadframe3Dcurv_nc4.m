function dat = loadframe3Dcurv_nc4(fn)

narginchk(1,1)
%% SIMULATION RESULTS
dat.filename = fn;

if isoctave
  pkg('load','netcdf')
end

dat.ns = ncread(fn, 'nsall');
dat.vs1 = ncread(fn, 'vs1all');
dat.Ts = ncread(fn, 'Tsall');
dat.J1 = ncread(fn, 'J1all');
dat.J2 = ncread(fn, 'J2all');
dat.J3 = ncread(fn, 'J3all');
dat.v2 = ncread(fn, 'v2avgall');
dat.v3 = ncread(fn, 'v3avgall');
dat.Phitop = ncread(fn, 'Phiall');

dat.J1 = squeeze(dat.J1);
dat.J2 = squeeze(dat.J2);
dat.J3 = squeeze(dat.J3);
dat.v2 = squeeze(dat.v2);
dat.v3 = squeeze(dat.v3);

end % function
