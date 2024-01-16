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

%% find msis_setup executable
exe = gemini3d.find.gemini_exe("msis_setup");
assert(~isempty(exe), "gemini3d:model:msis:FileNotFoundError", "Please clone and install https://github.com/gemini3d/external.git to setup Gemini3D msis_setup")

%% MSIS file API
% binary files are MUCH faster than stdin/stdout pipes

msis_infile = tempname;
msis_outfile = tempname;

msis_input(p, xg, time, msis_infile)

msis_run(exe, msis_infile, msis_outfile)

atmos = msis_output(msis_outfile);
atmos.time = time;

end % function


function msis_input(p, xg, time, file)

import stdlib.h5save

if isfield(p, "msis_version")
  msis_version = p.msis_version;
else
  msis_version = 0;
end

%% CONVERT DATES/TIMES/INDICES INTO MSIS-FRIENDLY FORMAT
if isfield(p, 'activ')
  f107a = p.activ(1);
  f107 = p.activ(2);
  ap = p.activ(3);
else
  assert(all(isfield(p, ["f107a", "f107", "Ap"])), "gemini3d:model:msis:keyError", "MSIS initialization requires config fields: f107a, f107, Ap")
  f107a = p.f107a;
  f107 = p.f107;
  ap = p.Ap;
end

doy = day(time, 'dayofyear');
UTsec0 = seconds(time - datetime(time.Year, time.Month, time.Day));
% KLUDGE THE BELOW-ZERO ALTITUDES SO THAT THEY DON'T GIVE INF
alt = xg.alt/1e3;
alt(alt <= 0) = 1;

h5save(file, "/msis_version", msis_version, 'type', 'int32')
h5save(file, "/doy", doy, 'type', 'int32')
h5save(file, "/UTsec", UTsec0)
h5save(file, "/f107a", f107a)
h5save(file, "/f107", f107)
h5save(file, "/Ap", repmat(ap, [1, 7]))
% float32 to save disk IO time/space
% ensure the disk array has 3 dimensions--Matlab collapses to 2D and that's not
% suitable for Fortran
h5save(file, "/glat", xg.glat, 'size', xg.lx, 'type', 'float32');
h5save(file, "/glon", xg.glon, 'size', xg.lx, 'type', 'float32');
h5save(file, "/alt", alt, 'size', xg.lx, 'type', 'float32');

end


function msis_run(exe, in, out)

if stdlib.is_wsl_path(exe)
  cmd = ["wsl", stdlib.winpath2wslpath(exe), stdlib.winpath2wslpath(in), stdlib.winpath2wslpath(out)];
else
  cmd = [exe, in, out];
end

disp(join(cmd, " "))
[stat, ~, stderr] = stdlib.sys.subprocess_run(cmd);
% output written to file
switch stat
  case 0  % good
  case -1073741515, error("if on Windows, is libgfortran on PATH?")
    otherwise, error('problem running MSIS %s %s', strjoin(cmd), stderr)
end

assert(isfile(out), "gemini3d:model:msis:FileNotFoundError", "MSIS output file %s not found, did msis_setup %s run properly?", out, exe)

end


function atmos = msis_output(file)

atmos.nO = h5read(file, "/nO");
atmos.nN2 = h5read(file, "/nN2");
atmos.nO2 = h5read(file, "/nO2");
atmos.Tn = h5read(file, "/Tn");
atmos.nN = h5read(file, "/nN");
atmos.nNO = 0.4 * exp(-3700./ atmos.Tn) .* atmos.nO2 + 5e-7* atmos.nO;       %Mitra, 1968
atmos.nH = h5read(file, "/nH");

end
