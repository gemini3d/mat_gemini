classdef TestUnit < matlab.unittest.TestCase

methods (Test)

function test_expanduser(tc)

import stdlib.fileio.expanduser

tc.verifyFalse(startsWith(expanduser('~/foo'), "~"))
tc.verifyFalse(any(startsWith(expanduser(["~/abc", "~/123"]), "~")))

tc.verifyTrue(endsWith(expanduser('~/foo'), "foo"))
tc.verifyTrue(all(endsWith(expanduser(["~/abc", "~/123"]), ["abc", "123"])))

tc.verifyEmpty(expanduser(string.empty))
tc.verifyEqual(expanduser(""), "")
end

function test_posix(tc)
import stdlib.fileio.posix

if ispc
  tc.verifyFalse(contains(posix("c:\foo"), "\"))
  tc.verifyFalse(any(contains(posix(["x:\123", "d:\abc"]), "\")))
end

tc.verifyEmpty(posix(string.empty))
end

function test_is_absolute_path(tc)

import stdlib.fileio.is_absolute_path

% path need not exist
tc.verifyTrue(is_absolute_path('~/foo'))
if ispc
  tc.verifyTrue(is_absolute_path('x:/foo'))
  tc.verifyEqual(is_absolute_path(["x:/abc", "x:/123", "", "c"]), [true, true, false, false])
  tc.verifyTrue(all(is_absolute_path(["x:/abc"; "x:/123"])))
  tc.verifyFalse(is_absolute_path('/foo'))
else
  tc.verifyTrue(is_absolute_path('/foo'))
end

tc.verifyEmpty(is_absolute_path(string.empty))
tc.verifyFalse(is_absolute_path(""))
tc.verifyFalse(is_absolute_path("c"))
end

function test_absolute_path(tc)

import stdlib.fileio.absolute_path

pabs = absolute_path('2foo');
pabs2 = absolute_path('4foo');
tc.verifyFalse(startsWith(pabs, "2"))
tc.verifyTrue(strncmp(pabs, pabs2, 2))

par1 = absolute_path("../2foo");
par2 = absolute_path("../4foo");
tc.verifyFalse(startsWith(par1, ".."))
tc.verifyTrue(strncmp(par2, pabs2, 2))

pt1 = absolute_path("bar/../2foo");
tc.verifyFalse(contains(pt1, ".."))

va = absolute_path(["2foo", "4foo"]);
tc.verifyFalse(any(startsWith(va, "2")))
vs = extractBefore(va, 2);
tc.verifyEqual(vs(1), vs(2))

tc.verifyEmpty(absolute_path(string.empty))
tc.verifyEqual(absolute_path(""), string(pwd))
end

function test_makedir(tc)

import stdlib.fileio.makedir
d = tempname;
makedir(d)
tc.assertTrue(isfolder(d))
end

function test_which(tc)

import stdlib.fileio.which

tc.verifyEmpty(which(string.empty))

n = "matlab";
% assumes Matlab in environment variable PATH
tc.assumeNotEmpty(which(n))

p = fullfile(matlabroot, "bin", n);

% full absolute path
exe = which(p);

if ispc
  tc.verifyTrue(endsWith(exe, ".exe"))
else
  tc.verifyFalse(endsWith(exe, ".exe"))
end
tc.assertTrue(isfile(exe))

end

function test_with_suffix(tc)

import stdlib.fileio.with_suffix

tc.verifyEqual(with_suffix("foo.h5", ".nc"), "foo.nc")
if ~verLessThan("matlab", "9.9")
% fileparts vectorized in R2020b
tc.verifyEqual(with_suffix(["foo.h5", "bar.dat"], ".nc"), ["foo.nc", "bar.nc"])

tc.verifyEmpty(with_suffix(string.empty, ".nc"))
tc.verifyEqual(with_suffix("", ""), "")
tc.verifyEqual(with_suffix("c", ""), "c")
tc.verifyEqual(with_suffix("c.nc", ""), "c")
tc.verifyEqual(with_suffix("", ".nc"), ".nc")
end
end

function test_path_tail(tc)

import stdlib.fileio.path_tail

tc.verifyEqual(path_tail("a/b/c.h5"), "c.h5")
tc.verifyEqual(path_tail("c.h5"), "c.h5")
tc.verifyEqual(path_tail("a/b/c/"), "c")

if ~verLessThan("matlab", "9.9")
% fileparts vectorized in R2020b
tc.verifyEqual(path_tail(["c.h5", "a/b/c/"]), ["c.h5", "c"])

tc.verifyEmpty(path_tail(string.empty))
tc.verifyEqual(strlength(path_tail("")), 0)

tc.verifyEqual(path_tail(["", "a/b"]), ["", "b"])
tc.verifyEqual(path_tail("c"), "c")
end
end

function test_nml_gemini_simroot(tc)

import gemini3d.fileio.expand_simroot

old = getenv("GEMINI_SIMROOT");

setenv("GEMINI_SIMROOT", "abc123")

out = expand_simroot("@GEMINI_SIMROOT@/foo");

setenv("GEMINI_SIMROOT", old)

tc.verifyEqual(out, fullfile("abc123", "foo"))


end


function test_grid1d(tc)

x = gemini3d.grid.grid1d(100., 5);
tc.verifyEqual(x, -100:25:100, 'RelTol', 1e-6, 'AbsTol', 1e-8)

x = gemini3d.grid.grid1d(100., 5, [200, 0.5, 9.5, 10]);
tc.verifyEqual(x, [-50.25, -40.25, -30.25, -20.25, -10.25, -0.25, 0.25, 10.25, 20.25, 30.25, 40.25, 50.25], ...
  'RelTol', 1e-6, 'AbsTol', 1e-8)

end

function test_dateinc(tc)
[ymd3, utsec] = gemini3d.dateinc(1.5, [2020, 1, 1], 86399);
tc.verifyEqual(ymd3, [2020,1,2])
tc.verifyEqual(utsec, 0.5, 'AbsTol', 1e-6)
end

function test_version(tc)
tc.verifyTrue(gemini3d.version_atleast("3.19.0.33", "3.19.0"))
tc.verifyFalse(gemini3d.version_atleast("3.19.0.33", "3.19.0.34"))
end

function test_max_mpi(tc)
tc.verifyEqual(gemini3d.sys.max_mpi([48,1,40], 5), 5)
tc.verifyEqual(gemini3d.sys.max_mpi([48,40,1], 5),  5)
tc.verifyEqual(gemini3d.sys.max_mpi([48,1,40], 6),  5)
tc.verifyEqual(gemini3d.sys.max_mpi([48,40,1], 6),  5)
tc.verifyEqual(gemini3d.sys.max_mpi([48,1,40], 8),  8)
tc.verifyEqual(gemini3d.sys.max_mpi([48,1,40], 18), 10)
tc.verifyEqual(gemini3d.sys.max_mpi([48,1,40], 64), 40)
tc.verifyEqual(gemini3d.sys.max_mpi([48,40,1], 8),  8)
tc.verifyEqual(gemini3d.sys.max_mpi([48,1,40], 28),  20)
tc.verifyEqual(gemini3d.sys.max_mpi([48,12,8], 8), 8)
tc.verifyEqual(gemini3d.sys.max_mpi([48,12,8], 18), 16)
tc.verifyEqual(gemini3d.sys.max_mpi([48,40,36], 28),  24)
tc.verifyEqual(gemini3d.sys.max_mpi([48,44,54], 28),  27)
tc.verifyEqual(gemini3d.sys.max_mpi([48,54,44], 28),  27)
tc.verifyEqual(gemini3d.sys.max_mpi([48,54,44], 96),  88)
tc.verifyEqual(gemini3d.sys.max_mpi([48,54,44], 128), 108)
tc.verifyEqual(gemini3d.sys.max_mpi([48,54,44], 256), 216)
tc.verifyEqual(gemini3d.sys.max_mpi([48,54,44], 512), 396)
tc.verifyEqual(gemini3d.sys.max_mpi([48,54,44], 1024), 792)
end

function test_coord(tc)

[lat, lon] = gemini3d.geomag2geog(pi/2, pi/2);
tc.verifyEqual([lat, lon], [0, 19], 'AbsTol', 1e-6, 'RelTol', 0.001)

[theta, phi] = gemini3d.geog2geomag(0,0);
tc.verifyEqual([theta, phi], [1.50863496978059, 1.24485046147953], 'AbsTol', 1e-6, 'RelTol', 0.001)

[alt, lon, lat] = gemini3d.UEN2geog(0,0,0, pi/2, pi/2);
tc.verifyEqual([alt, lat, lon], [0, 0, 19], 'AbsTol', 1e-6, 'RelTol', 0.001)

[z,x,y] = gemini3d.geog2UEN(0, 0, 0, pi/2, pi/2);
tc.verifyEqual([z,x,y], [0, -2076275.16205889, 395967.844181141], 'AbsTol', 1e-6, 'RelTol', 0.001)

end

end

end
