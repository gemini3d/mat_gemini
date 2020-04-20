function dat = loadframe3Dcurvnoelec_raw(filename)
%% READ IN SIMULATION DATA WITH NO ELECTRODYNAMIC PARAMS SUCH AS FROM AN INPUT FILE
narginchk(1,1)
%% SIMULATION SIZE
lsp=7;
lxs = simsize(filename);
%% SIMULATION RESULTS
assert(is_file(fsimres), [filename,' is not a file.'])
dat.filename = filename;

fid = fopen(filename, 'r');
dat.simdate = simdt(fid);

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
