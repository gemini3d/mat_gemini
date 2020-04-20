function dat = loadframe3Dcurvavg_hdf5(filename)

narginchk(1,1)
%% SIMULATIONS RESULTS
assert(is_file(filename), [filename,' does not exist '])
dat.filename = filename;

% simdate=zeros(1,6);    %datevec-style array

if isoctave
  D = load(filename);
  %dat.simdate(1:3) = D.time.ymd;
  %dat.simdate(4) = D.time.UThour;
  dat.ne = D.neall;
  dat.v1 = D.v1avgall;
  dat.Ti = D.Tavgall;
  dat.Te = D.TEall;
  dat.J1 = D.J1all;
  dat.J2 = D.J2all;
  dat.J3 = D.J3all;
  dat.v2 = D.v2avgall;
  dat.v3 = D.v3avgall;
  dat.Phitop = D.Phiall;
else
  %dat.simdate(1:3) = h5read(filename, '/time/ymd');
  %dat.simdate(4) = h5read(filename, '/time/UThour');
  %% Number densities
  dat.ne = h5read(filename, '/neall');
  %% Parallel Velocities
  dat.v1 = h5read(filename, '/v1avgall');
  %% Temperatures
  dat.Ti = h5read(filename, '/Tavgall');
  dat.Te = h5read(filename, '/TEall');
  %% Current densities
  dat.J1 = h5read(filename, '/J1all');
  dat.J2 = permute(h5read(filename, '/J2all'), [1,3,2]);
  dat.J3 = permute(h5read(filename, '/J3all'), [1,3,2]);
  %% Perpendicular drifts
  dat.v2 = h5read(filename, '/v2avgall');
  dat.v3 = h5read(filename, '/v3avgall');
  %% Topside potential
  dat.Phitop = h5read(filename, '/Phiall');
end

end % function
