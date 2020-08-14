function dat = loadframe3Dcurv_raw(filename)
import gemini3d.fileio.*
import gemini3d.vis.*

narginchk(1,1)
%% SIMULATION SIZE
lsp=7;
lxs = gemini3d.simsize(filename);
%% SIMULATION RESULTS
dat.filename = filename;

fid=fopen(filename,'r');

dat.time = get_time(fid);
%% load densities
dat.ns = read4D(fid, lsp, lxs);
%% load Vparallel
dat.vs1 = read4D(fid, lsp, lxs);
%% load temperatures
dat.Ts = read4D(fid, lsp, lxs);
%% load current densities
dat.J1 = read3D(fid, lxs);
dat.J2 = read3D(fid, lxs);
dat.J3 = read3D(fid, lxs);
%% load Vperp
dat.v2 = read3D(fid, lxs);
dat.v3 = read3D(fid, lxs);
%% load topside potential
dat.Phitop = read2D(fid, lxs);

fclose(fid);

%{
fid=fopen('neuinfo.dat','r');
ln=6;
nn=fscanf(fid,'%f',prod(lxs)*ln);
nn=reshape(nn,[lxs(1),lxs(2),lxs(3),ln]);
fclose(fid);
%}

end % function
