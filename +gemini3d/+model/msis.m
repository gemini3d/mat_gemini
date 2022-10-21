function atmos = msis(p, xg, time)
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

gemini3d.sys.check_stdlib()

if isfield(p, "msis_version")
  msis_version = p.msis_version;
else
  msis_version = 0;
end

%% find or build msis_setup executable
exe = gemini3d.find.gemini_exe("msis_setup");
if isempty(exe)
  error("gemini3d:model:msis:FileNotFoundError", "Please clone and install https://github.com/gemini3d/external.git to setup Gemini3D msis_setup")
end

%% CONVERT DATES/TIMES/INDICES INTO MSIS-FRIENDLY FORMAT
if isfield(p, 'activ')
  f107a = p.activ(1);
  f107 = p.activ(2);
  ap = p.activ(3);
else
  f107a = p.f107a;
  f107 = p.f107;
  ap = p.Ap;
end

doy = day(time, 'dayofyear');
UTsec0 = seconds(time - datetime(time.Year, time.Month, time.Day));
% KLUDGE THE BELOW-ZERO ALTITUDES SO THAT THEY DON'T GIVE INF
alt = xg.alt/1e3;
alt(alt <= 0) = 1;
%% MSIS file API
% we use binary files because they are MUCH faster than stdin/stdout pipes
% we need absolute paths because MSIS 2 requires a chdir() due to Matlab
% system() not having cwd= like Python.
msis_infile = tempname + "-msis_setup_in.h5";
msis_outfile = tempname + "-msis_setup_out.h5";

% even though filename is guaranteed unique, in case of weird corner case.
if isfile(msis_infile)
  warning("msis_infile exists, this may fail to write " + msis_infile)
end
if isfile(msis_outfile)
  warning("msis_outfile exist, this may fail to write " + msis_outfile)
end

stdlib.hdf5nc.h5save(msis_infile, "/msis_version", msis_version, 'type', 'int32')
stdlib.hdf5nc.h5save(msis_infile, "/doy", doy, 'type', 'int32')
stdlib.hdf5nc.h5save(msis_infile, "/UTsec", UTsec0)
stdlib.hdf5nc.h5save(msis_infile, "/f107a", f107a)
stdlib.hdf5nc.h5save(msis_infile, "/f107", f107)
stdlib.hdf5nc.h5save(msis_infile, "/Ap", repmat(ap, [1, 7]))
% float32 to save disk IO time/space
% ensure the disk array has 3 dimensions--Matlab collapses to 2D and that's not
% suitable for Fortran
stdlib.hdf5nc.h5save(msis_infile, "/glat", xg.glat, 'size', xg.lx, 'type', 'float32');
stdlib.hdf5nc.h5save(msis_infile, "/glon", xg.glon, 'size', xg.lx, 'type', 'float32');
stdlib.hdf5nc.h5save(msis_infile, "/alt", alt, 'size', xg.lx, 'type', 'float32');

%% CALL MSIS

if msis_version == 20
  % limitation of Matlab system() vis pwd
  old_pwd = pwd;
  cd(fileparts(exe))
end
cmd = [exe, msis_infile, msis_outfile];
[status, msg] = stdlib.sys.subprocess_run(cmd);
% output written to file
if msis_version == 20
  cd(old_pwd)
end

switch status
  case -1073741515, error("if on Windows, is libgfortran on PATH?")
  case 0  % good
  otherwise, error('problem running MSIS %s %s', strjoin(cmd), msg)
end

%% load MSIS output
atmos.nO = h5read(msis_outfile, "/nO");
atmos.nN2 = h5read(msis_outfile, "/nN2");
atmos.nO2 = h5read(msis_outfile, "/nO2");
atmos.Tn = h5read(msis_outfile, "/Tn");
atmos.nN = h5read(msis_outfile, "/nN");
atmos.nNO = 0.4 * exp(-3700./ atmos.Tn) .* atmos.nO2 + 5e-7* atmos.nO;       %Mitra, 1968
atmos.nH = h5read(msis_outfile, "/nH");
atmos.time = time;

end % function
