function dat = frame3Dcurvavg_raw(filename)
arguments
  filename (1,1) string
end
%% SIMULATION SIZE
lxs = gemini3d.simsize(filename);
%% SIMULATION GRID FILE
% (NOTE THAT THIS IS NOT THE ENTIRE THING - THAT NEEDS TO BE DONE WITH READGRID.M.  WE NEED THIS HERE TO DO MESHGRIDS
%[x1, x2, x3] = simaxes(filename);
%% SIMULATION RESULTS
assert(isfile(filename), '%s is not a file.', filename)
dat.filename = filename;

fid = fopen(filename,'r');

dat.time = gemini3d.read.time(fid);
%% Number densities
dat.ne = read3D(fid, lxs);
%% Parallel Velocities
dat.v1 = read3D(fid, lxs);
%% Temperatures
dat.Ti = read3D(fid, lxs);
dat.Te = read3D(fid, lxs);
%% Current densities
dat.J1 = read3D(fid, lxs);
dat.J2 = read3D(fid, lxs);
dat.J3 = read3D(fid, lxs);
%% Perpendicular drifts
dat.v2 = read3D(fid, lxs);
dat.v3 = read3D(fid, lxs);
%% Topside potential
dat.Phitop = read2D(fid, lxs);

fclose(fid);

end % function
