function dat = loadframe3Dcurvavg_raw(filename, vars)

narginchk(2,2)
%% SIMULATION SIZE
lxs = gemini3d.simsize(filename);
%% SIMULATION GRID FILE
% (NOTE THAT THIS IS NOT THE ENTIRE THING - THAT NEEDS TO BE DONE WITH READGRID.M.  WE NEED THIS HERE TO DO MESHGRIDS
%[x1, x2, x3] = simaxes(filename);
%% SIMULATION RESULTS
assert(isfile(filename), '%s is not a file.', filename)
dat.filename = filename;

fid = fopen(filename,'r');

dat.time = gemini3d.vis.get_time(fid);
%% Number densities
dat.ne = gemini3d.vis.read3D(fid, lxs);
if length(vars) == 1 && strcmp(vars{1}, 'ne')
  fclose(fid);
  return
end
%% Parallel Velocities
dat.v1 = gemini3d.vis.read3D(fid, lxs);
%% Temperatures
dat.Ti = gemini3d.vis.read3D(fid, lxs);
dat.Te = gemini3d.vis.read3D(fid, lxs);
%% Current densities
dat.J1 = gemini3d.vis.read3D(fid, lxs);
dat.J2 = gemini3d.vis.read3D(fid, lxs);
dat.J3 = gemini3d.vis.read3D(fid, lxs);
%% Perpendicular drifts
dat.v2 = gemini3d.vis.read3D(fid, lxs);
dat.v3 = gemini3d.vis.read3D(fid, lxs);
%% Topside potential
dat.Phitop = gemini3d.vis.read2D(fid, lxs);

fclose(fid);

end % function
