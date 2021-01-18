function natm = msis(p, xg, time)
%% calls MSIS Fortran executable from Matlab.
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
arguments
  p (1,1) struct
  xg (1,1) struct
  time (1,1) datetime = p.times(1)
end

%% path to msis executable
cwd = fileparts(mfilename('fullpath'));
src_dir = getenv("MATGEMINI");
if isempty(src_dir)
  src_dir = fullfile(cwd, "../..");
end
build_dir = fullfile(src_dir, "build");
exe = fullfile(build_dir, "msis_setup");
if ispc
  exe = exe + ".exe";
end

%% build exe if not present
if ~isfile(exe)
  gemini3d.sys.cmake(src_dir, build_dir)
end

assert (isfile(exe), 'MSIS setup executable not found: %s', exe)

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

doy = day(time, 'dayofyear');
UTsec0 = seconds(time - datetime(time.Year, time.Month, time.Day));
% KLUDGE THE BELOW-ZERO ALTITUDES SO THAT THEY DON'T GIVE INF
alt(alt <= 0) = 1;
%% temporary files for MSIS
% we use binary files because they are MUCH faster than stdin/stdout pipes
% for large simulations

fin = tempname + "_msis_in.dat";
fout = tempname + "_msis_out.dat";
% need a unique input temporary filename for parallel runs

fid=fopen(fin,'w');
fwrite(fid, doy,'integer*4');
fwrite(fid, UTsec0,'integer*4');
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
cmd = exe + " " + fin + " " + fout + " " + lz;
if isfield(p, "msis_version") && ~isempty(p.msis_version)
  cmd = cmd + " " + int2str(p.msis_version);

  if p.msis_version == 20
    msis20_file = fullfile(build_dir, 'msis20.parm');
    assert(isfile(msis20_file), msis20_file + "%s not found")
  end
end
% disp(cmd)

% limitation of Matlab system() vis pwd for msis20.parm
old_pwd = pwd;
cd(build_dir)
[status, msg] = system(cmd);   %output written to file
cd(old_pwd)
assert(status==0, 'problem running MSIS %s', msg)

%% binary output
% using stdout becomes a problem due to 100's of MBs of output for non-trival simulation grids.
% so keep this as a binary file.
fid = fopen(fout, 'r');
msis_dat = fread(fid,lz*11, 'float32=>float32');
fclose(fid);

msis_dat = transpose(reshape(msis_dat,[11 lz]));
%% stdout
% (Not used, for reference)
% msis_dat = cell2mat(textscan(msg, '%f %f %f %f %f %f %f %f %f %f %f', lz, 'CollectOutput', true, 'ReturnOnError', false));
%% ORGANIZE
assert(all(size(msis_dat) == [lz, 11]), 'msis_setup did not return expected shape')
% wait to delete until we think msis_setup worked, for debugging.
delete(fin);
delete(fout);

nO=reshape(msis_dat(:,3), xg.lx);
nN2=reshape(msis_dat(:,4), xg.lx);
nO2=reshape(msis_dat(:,5), xg.lx);
Tn=reshape(msis_dat(:,11), xg.lx);
nN=reshape(msis_dat(:,9), xg.lx);
nNO=4e-1*exp(-3700./Tn).*nO2+5e-7*nO;       %Mitra, 1968
nH=reshape(msis_dat(:,8), xg.lx);
natm=cat(4,nO,nN2,nO2,Tn,nN,nNO,nH);

end % function
