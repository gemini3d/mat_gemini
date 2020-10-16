classdef TestAUnit < matlab.unittest.TestCase

methods (Test)

function test_expanduser(tc)
tc.verifyFalse(startsWith(gemini3d.fileio.expanduser('~/foo'), "~"))
tc.verifyFalse(any(startsWith(gemini3d.fileio.expanduser(["~/abc", "~/123"]), "~")))

tc.verifyTrue(endsWith(gemini3d.fileio.expanduser('~/foo'), "foo"))
tc.verifyTrue(all(endsWith(gemini3d.fileio.expanduser(["~/abc", "~/123"]), ["abc", "123"])))

tc.verifyEmpty(gemini3d.fileio.expanduser(string.empty))
end

function test_posix(tc)
if ispc
  tc.verifyFalse(contains(gemini3d.posix("c:\foo"), "\"))
end

tc.verifyEmpty(gemini3d.posix(string.empty))
end

function test_is_absolute_path(tc)
% path need not exist
tc.verifyTrue(gemini3d.fileio.is_absolute_path('~/foo'))
if ispc
  tc.verifyTrue(gemini3d.fileio.is_absolute_path('x:/foo'))
  tc.verifyTrue(all(gemini3d.fileio.is_absolute_path(["x:/abc", "x:/123"])))
  tc.verifyTrue(all(gemini3d.fileio.is_absolute_path(["x:/abc"; "x:/123"])))
  tc.verifyFalse(gemini3d.fileio.is_absolute_path('/foo'))
else
  tc.verifyTrue(gemini3d.fileio.is_absolute_path('/foo'))
end

tc.verifyEmpty(gemini3d.fileio.is_absolute_path(string.empty))
end

function test_absolute_path(tc)
pabs = gemini3d.fileio.absolute_path('2foo');
pabs2 = gemini3d.fileio.absolute_path('4foo');
tc.verifyFalse(startsWith(pabs, "2"))
tc.verifyTrue(strncmp(pabs, pabs2, 2))

par1 = gemini3d.fileio.absolute_path("../2foo");
par2 = gemini3d.fileio.absolute_path("../4foo");
tc.verifyFalse(startsWith(par1, ".."))
tc.verifyTrue(strncmp(par2, pabs2, 2))

pt1 = gemini3d.fileio.absolute_path("bar/../2foo");
tc.verifyFalse(contains(pt1, ".."))

va = gemini3d.fileio.absolute_path(["2foo", "4foo"]);
tc.verifyFalse(any(startsWith(va, "2")))
vs = extractBefore(va, 2);
tc.verifyEqual(vs(1), vs(2))

tc.verifyEmpty(gemini3d.fileio.absolute_path(string.empty))
end

function test_with_suffix(tc)
tc.verifyEqual(gemini3d.fileio.with_suffix("foo.h5", ".nc"), "foo.nc")
tc.verifyEqual(gemini3d.fileio.with_suffix(["foo.h5", "bar.dat"], ".nc"), ["foo.nc", "bar.nc"])
tc.verifyEmpty(gemini3d.fileio.with_suffix(string.empty, ".nc"))
end

function test_path_tail(tc)
tc.verifyEqual(gemini3d.fileio.path_tail("a/b/c.h5"), "c.h5")
tc.verifyEqual(gemini3d.fileio.path_tail("c.h5"), "c.h5")
tc.verifyEqual(gemini3d.fileio.path_tail("a/b/c/"), "c")

tc.verifyEqual(gemini3d.fileio.path_tail(["c.h5", "a/b/c/"]), ["c.h5", "c"])

tc.verifyEmpty(gemini3d.fileio.path_tail(string.empty))
end


function test_dateinc(tc)
[ymd3, utsec] = gemini3d.dateinc(1.5, [2020, 1, 1], 86399);
tc.verifyEqual(ymd3, [2020,1,2])
tc.verifyEqual(utsec, 0.5, 'Abstol', 1e-6)
end

function test_git_revision(tc)
tc.verifyClass(gemini3d.git_revision(), "struct")
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
tc.verifyEqual(gemini3d.sys.max_mpi([48,40,1], 8),  8)
tc.verifyEqual(gemini3d.sys.max_mpi([48,1,40], 28),  20)
tc.verifyEqual(gemini3d.sys.max_mpi([48,1,40], 28),  20)
tc.verifyEqual(gemini3d.sys.max_mpi([48,1,36], 28),  18)
end

end

end
