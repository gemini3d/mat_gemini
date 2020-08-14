function dat = loadframe3Dcurvavg_hdf5(filename)
import gemini3d.fileio.*

narginchk(1,1)
%% SIMULATIONS RESULTS
dat.filename = filename;

%% Number densities
dat.ne = h5read(filename, '/neall');
%% Parallel Velocities
dat.v1 = h5read(filename, '/v1avgall');
%% Temperatures
dat.Ti = h5read(filename, '/Tavgall');
dat.Te = h5read(filename, '/TEall');
%% Current densities
dat.J1 = h5read(filename, '/J1all');
%  dat.J2 = permute(h5read(filename, '/J2all'), [1,3,2]);
%  dat.J3 = permute(h5read(filename, '/J3all'), [1,3,2]);
dat.J2 = h5read(filename, '/J2all');
dat.J3 = h5read(filename, '/J3all');
%% Perpendicular drifts
dat.v2 = h5read(filename, '/v2avgall');
dat.v3 = h5read(filename, '/v3avgall');
%% Topside potential
dat.Phitop = h5read(filename, '/Phiall');

end % function
