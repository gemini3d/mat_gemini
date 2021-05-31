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

import stdlib.fileio.absolute_path
import stdlib.fileio.expanduser
import stdlib.fileio.which
import stdlib.sys.subprocess_run
import gemini3d.sys.cmake
import stdlib.hdf5nc.h5save

if isfield(p, "msis_version")
  msis_version = p.msis_version;
else
  msis_version = 0;
end

%% path to msis executable
src_dir = expanduser(getenv("GEMINI_ROOT"));
assert(isfolder(src_dir), "Please set environment variable GEMINI_ROOT to top-level Gemini3D folder.")
build_dir = fullfile(src_dir, "build");
exe = which("msis_setup", build_dir);

%% build exe if not present
if isempty(exe)
  cmake(src_dir, build_dir, "msis_setup")
end
exe = which("msis_setup", build_dir);
assert(~isempty(exe), 'MSIS setup executable not found: %s', exe)

%% SPECIFY SIZES ETC.
alt=xg.alt/1e3;
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
alt(alt <= 0) = 1;
%% MSIS file API
% we use binary files because they are MUCH faster than stdin/stdout pipes
% we need absolute paths because MSIS 2.0 requires a chdir() due to Matlab
% system() not having cwd= like Python.
if isfield(p, "msis_infile")
  msis_infile = p.msis_infile;
else
  msis_infile = fullfile(fileparts(p.indat_size), "msis_setup_in.h5");
end
msis_infile = absolute_path(msis_infile);
if ~isfolder(fileparts(msis_infile))
  warning('model:msis:FolderNotFound', 'msis_infile not an absolute path. Falling back to tempdir')
  msis_infile = fullfile(tempdir, 'msis_setup_in.h5');
end

if isfield(p, "msis_outfile")
  msis_outfile = p.msis_outfile;
else
  msis_outfile = fullfile(fileparts(p.indat_size), "msis_setup_out.h5");
end
msis_outfile = absolute_path(msis_outfile);
if ~isfolder(fileparts(msis_outfile))
  warning('model:msis:FolderNotFound', 'msis_outfile not an absolute path. Falling back to tempdir')
  msis_outfile = fullfile(tempdir, 'msis_setup_in.h5');
end

if isfile(msis_infile)
  delete(msis_infile)
end
if isfile(msis_outfile)
  delete(msis_outfile)
end

h5save(msis_infile, "/doy", doy)
h5save(msis_infile, "/UTsec", UTsec0)
h5save(msis_infile, "/f107a", f107a)
h5save(msis_infile, "/f107", f107)
h5save(msis_infile, "/Ap", repmat(ap, [1, 7]))
% float32 to save disk IO time/space
% ensure the disk array has 3 dimensions--Matlab collapses to 2D and that's not
% suitable for Fortran
h5save(msis_infile, "/glat", xg.glat, 'size', xg.lx, 'type', 'float32');
h5save(msis_infile, "/glon", xg.glon, 'size', xg.lx, 'type', 'float32');
h5save(msis_infile, "/alt", alt, 'size', xg.lx, 'type', 'float32');

%% CALL MSIS
if msis_version == 20
  msis20_file = fullfile(build_dir, 'msis20.parm');
  assert(isfile(msis20_file), "%s not found", msis20_file)
end

if msis_version == 20
  % limitation of Matlab system() vis pwd for msis20.parm
  old_pwd = pwd;
  cd(build_dir)
end
[status, msg] = subprocess_run([exe, msis_infile, msis_outfile, int2str(msis_version)]);
% output written to file
if msis_version == 20
  cd(old_pwd)
end

switch status
  case -1073741515, error("if on Windows, is libgfortran on PATH?")
  case 0  % good
  otherwise, error('problem running MSIS %s', msg)
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
