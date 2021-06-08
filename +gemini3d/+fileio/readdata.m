function [t,ns,Ts,vs1,J1,J2,J3,v2,v3,Phitop] = readdata(lxs,filename)
%% READDATA is for deprecated raw binary files and is not typically used.
arguments
  lxs (3,1) {mustBeInteger,mustBePositive}
  filename (1,1) string
end

lsp = 7;

assert(isfile(filename), '%s not found.', filename)
%% READ DATA FROM AN OUTPUT FILE WRITTEN BY FORTRAN CODE

fid=fopen(filename,'r');
t=fread(fid,1,'real*8');

ns=fread(fid,prod(lxs)*lsp,'real*8');
ns=reshape(ns,[lxs,lsp]);
disp('READDATA --> Loaded densities...')

vs1=fread(fid,prod(lxs)*lsp,'real*8');
vs1=reshape(vs1,[lxs,lsp]);
% v1=sum(ns(:,:,:,1:6).*vs1(:,:,:,1:6),4)./ns(:,:,:,lsp);
disp('READDATA --> Loaded parallel velocities...')

Ts=fread(fid,prod(lxs)*lsp,'real*8');
Ts=reshape(Ts,[lxs,lsp]);
disp('READDATA --> Loaded temperatures...')

if ~feof(fid)   %some files may not have electrodynamic info
    J1=fread(fid,lxs(1)*lxs(2)*lxs(3),'real*8');
    J1=reshape(J1,[lxs(1),lxs(2),lxs(3)]);

    J2=fread(fid,lxs(1)*lxs(2)*lxs(3),'real*8');
    J2=reshape(J2,[lxs(1),lxs(2),lxs(3)]);

    J3=fread(fid,lxs(1)*lxs(2)*lxs(3),'real*8');
    J3=reshape(J3,[lxs(1),lxs(2),lxs(3)]);
    disp('READDATA --> Loaded current density...')

    v2=fread(fid,lxs(1)*lxs(2)*lxs(3),'real*8');
    v2=reshape(v2,[lxs(1),lxs(2),lxs(3)]);

    v3=fread(fid,lxs(1)*lxs(2)*lxs(3),'real*8');
    v3=reshape(v3,[lxs(1),lxs(2),lxs(3)]);
    disp('READDATA --> Loaded perpendicular drifts...')

    Phitop=fread(fid,lxs(2)*lxs(3),'real*8');
    Phitop=reshape(Phitop,[lxs(2),lxs(3)]);
    disp('READDATA --> Loaded topside potential pattern...')
else
    J1=[];
    J2=[];
    J3=[];
    v2=[];
    v3=[];
    Phitop=[];
    disp('READDATA --> Skipping electrodynamic parameters...')
end

fclose(fid);


end
