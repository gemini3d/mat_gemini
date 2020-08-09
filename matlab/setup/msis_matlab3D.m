function natm = msis_matlab3D(p, xg)
%% calls MSIS Fortran exectuable from Matlab.
% compiles if not present
%
% [f107a, f107, ap] = activ;
%     COLUMNS OF DATA:
%       1 - ALT
%       2 - HE NUMBER DENSITY(M-3)
%       3 - O NUMBER DENSITY(M-3)
%       4 - N2 NUMBER DENSITY(M-3)
%       5 - O2 NUMBER DENSITY(M-3)
%       6 - AR NUMBER DENSITY(M-3)
%       7 - TOTAL MASS DENSITY(KG/M3)
%       8 - H NUMBER DENSITY(M-3)
%       9 - N NUMBER DENSITY(M-3)
%       10 - Anomalous oxygen NUMBER DENSITY(M-3)
%       11 - TEMPERATURE AT ALT
%
narginchk(2,2)
validateattributes(p, {'struct'}, {'scalar'})
validateattributes(xg, {'struct'}, {'scalar'})

%% path to msis executable
cwd = fileparts(mfilename('fullpath'));
src_dir = fullfile(cwd, '../..');
build_dir = fullfile(src_dir, 'build');
exe = fullfile(build_dir, 'msis_setup');
if ispc, exe = [exe, '.exe']; end

%% build exe if not present
if ~is_file(exe)
  cmake(src_dir)
end

assert (is_file(exe), 'MSIS setup executable not found: %s', exe)

%% SPECIFY SIZES ETC.
lx1=xg.lx(1); lx2=xg.lx(2); lx3=xg.lx(3);
alt=xg.alt(:)/1e3;
glat=xg.glat(:);
glon=xg.glon(:);
lz=lx1*lx2*lx3;
%% CONVERT DATES/TIMES/INDICES INTO MSIS-FRIENDLY FORMAT
if isfield(p, 'activ')
  f107a = p.activ(1);
  f107 = p.activ(2);
  ap = p.activ(3);
  ap3 = p.activ(3);
else
  f107a = p.f107a;
  f107 = p.f107;
  ap = p.Ap;
  ap3 = p.Ap;
end
doy = day_of_year(p.ymd);

%fprintf('MSIS00 DOY %s\n', doy)
yearshort = mod(p.ymd(1),100);
iyd = yearshort*1000+doy;
%% KLUDGE THE BELOW-ZERO ALTITUDES SO THAT THEY DON'T GIVE INF
alt(alt <= 0) = 1;
%% CREATE INPUT FILE FOR FORTRAN PROGRAM
fin = tempname;
% need a unique input temporary filename for parallel runs

fid=fopen(fin,'w');
fwrite(fid,iyd,'integer*4');
fwrite(fid,p.UTsec0,'integer*4');
fwrite(fid,f107a,'real*4');
fwrite(fid,f107,'real*4');
fwrite(fid,ap,'real*4');
fwrite(fid,ap3,'real*4');
fwrite(fid,lz,'integer*4');
fwrite(fid,glat,'real*4');
fwrite(fid,glon,'real*4');
fwrite(fid,alt,'real*4');
fclose(fid);
%% CALL MSIS AND READ IN RESULTING BINARY FILE
cmd = sprintf('%s %s - %d',exe, fin, lz);
% disp(cmd)
prepend = modify_path();
[status, msg] = system([prepend, ' ', cmd]);   %output written to file
assert(status==0, 'problem running MSIS %s', msg)
delete(fin);
%% binary output
% fid=fopen(fout,'r');
% msis_dat=fread(fid,lz*11,'real*4=>real*8');
% msis_dat=reshape(msis_dat,[11 lz]);
% msis_dat=msis_dat';
% fclose(fid);
% delete(fout);
%% stdout
msis_dat = cell2mat(textscan(msg, '%f %f %f %f %f %f %f %f %f %f %f', lz, 'CollectOutput', true, 'ReturnOnError', false));
assert(all(size(msis_dat) == [lz, 11]), 'msis_setup did not return expected shape')
%% ORGANIZE
nO=reshape(msis_dat(:,3), xg.lx);
nN2=reshape(msis_dat(:,4), xg.lx);
nO2=reshape(msis_dat(:,5), xg.lx);
Tn=reshape(msis_dat(:,11), xg.lx);
nN=reshape(msis_dat(:,9), xg.lx);
nNO=4e-1*exp(-3700./Tn).*nO2+5e-7*nO;       %Mitra, 1968
nH=reshape(msis_dat(:,8), xg.lx);
natm=cat(4,nO,nN2,nO2,Tn,nN,nNO,nH);

end % function
