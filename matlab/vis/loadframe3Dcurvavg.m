function dat = loadframe3Dcurvavg(filename)

narginchk(1,1)
[~,~,ext] = fileparts(filename);

switch ext
  case '.h5', dat = loadframe3Dcurvavg_hdf5(filename);
  case '.dat', dat = loadframe3Dcurvavg_raw(filename);
  case '.nc', dat = loadframe3Dcurvavg_nc4(filename);
  otherwise, error('loadframe3Dcurvavg:value_error', 'unknown file type %s',filename)
end

lxs = simsize(filename);

%% REORGANIZE ACCORDING TO MATLABS CONCEPT OF A 2D or 3D DATA SET
if any(lxs(2:3) == 1)    %a 2D simulations was done in x1 and x3
  dat.ne = squeeze(dat.ne);
  dat.v1 = squeeze(dat.v1);
  dat.Ti = squeeze(dat.Ti);
  dat.Te = squeeze(dat.Te);
  dat.J1 = squeeze(dat.J1);
  dat.J2 = squeeze(dat.J2);
  dat.J3 = squeeze(dat.J3);
  dat.v2 = squeeze(dat.v2);
  dat.v3 = squeeze(dat.v3);
end

end % function
