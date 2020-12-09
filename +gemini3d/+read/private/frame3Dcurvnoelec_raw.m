function dat = frame3Dcurvnoelec_raw(filename)
%% READ IN SIMULATION DATA WITH NO ELECTRODYNAMIC PARAMS SUCH AS FROM AN INPUT FILE
arguments
  filename (1,1) string
end

%% SIMULATION SIZE
lsp=7;
lxs = gemini3d.simsize(filename);
%% SIMULATION RESULTS
dat.filename = filename;

fid = fopen(filename, 'r');

dat.time = get_time(fid);

dat.ns = read4D(fid, lsp, lxs);
dat.vs1 = read4D(fid, lsp, lxs);
dat.Ts = read4D(fid, lsp, lxs);

% J1 = read3D(fid, lxs);
%
% J2 = read3D(fid, lxs);
%
% J3 = read3D(fid, lxs);
%
% v2 = read3D(fid, lxs);
%
% v3 = read3D(fid, lxs);
%
% Phitop = read2D(fid, lxs);

fclose(fid);

%{
fid=fopen('neuinfo.dat','r');
ln=6;
nn=fscanf(fid,'%f',prod(lxs)*ln);
nn=reshape(nn,[lxs(1),lxs(2),lxs(3),ln]);
fclose(fid);
%}

end % function
