function dat = loadframe3Dcurv_raw(filename, vars)

narginchk(2,2)
%% SIMULATION SIZE
lsp=7;
lxs = gemini3d.simsize(filename);
%% SIMULATION RESULTS
dat.filename = filename;

fid=fopen(filename,'r');

dat.time = gemini3d.vis.get_time(fid);
%% load densities
dat.ns = gemini3d.vis.read4D(fid, lsp, lxs);
if length(vars) == 1 && strcmp(vars{1}, 'ne')
  fclose(fid);
  return
end
%% load Vparallel
dat.vs1 = gemini3d.vis.read4D(fid, lsp, lxs);
%% load temperatures
dat.Ts = gemini3d.vis.read4D(fid, lsp, lxs);
%% load current densities
dat.J1 = gemini3d.vis.read3D(fid, lxs);
dat.J2 = gemini3d.vis.read3D(fid, lxs);
dat.J3 = gemini3d.vis.read3D(fid, lxs);
%% load Vperp
dat.v2 = gemini3d.vis.read3D(fid, lxs);
dat.v3 = gemini3d.vis.read3D(fid, lxs);
%% load topside potential
dat.Phitop = gemini3d.vis.read2D(fid, lxs);

fclose(fid);

%{
fid=fopen('neuinfo.dat','r');
ln=6;
nn=fscanf(fid,'%f',prod(lxs)*ln);
nn=reshape(nn,[lxs(1),lxs(2),lxs(3),ln]);
fclose(fid);
%}

end % function
