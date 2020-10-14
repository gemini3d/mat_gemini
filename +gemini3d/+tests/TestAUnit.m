classdef TestAUnit < matlab.unittest.TestCase

properties (TestParameter)

end

methods (Test)

function test_expanduser(tc)
tc.assertFalse(startsWith(gemini3d.fileio.expanduser('~/foo'), "~"))
end

function test_posix(tc)
if ispc
  tc.assertFalse(contains(gemini3d.posix("c:\foo"), "\"))
end
end

function test_is_absolute_path(tc)
% path need not exist
tc.assertTrue(gemini3d.fileio.is_absolute_path('~/foo'))
if ispc
  tc.assertTrue(gemini3d.fileio.is_absolute_path('x:/foo'))
end
end

function test_absolute_path(tc)
pabs = gemini3d.fileio.absolute_path('2foo');
pabs2 = gemini3d.fileio.absolute_path('4foo');
tc.assertFalse(startsWith(pabs, "2"), 'absolute_path')
tc.assertTrue(strncmp(pabs, pabs2, 2), 'absolute_path 2 files')
end

function test_with_suffix(tc)
tc.assertEqual(gemini3d.fileio.with_suffix("foo.h5", ".nc"), "foo.nc")
end

function test_path_tail(tc)
tc.assertEqual(gemini3d.fileio.path_tail("a/b/c.h5"), "c.h5")
tc.assertEqual(gemini3d.fileio.path_tail("c.h5"), "c.h5")
tc.assertEqual(gemini3d.fileio.path_tail("a/b/c/"), "c")
end


function test_dateinc(tc)
[ymd3, utsec] = gemini3d.dateinc(1.5, [2020, 1, 1], 86399);
tc.assertEqual(ymd3, [2020,1,2])
tc.assertEqual(utsec, 0.5, 'Abstol', 1e-6)
end

function test_git_revision(tc)
tc.assertClass(gemini3d.git_revision(), "struct")
end

function test_version(tc)
tc.assertTrue(gemini3d.version_atleast("3.19.0.33", "3.19.0"))
tc.assertFalse(gemini3d.version_atleast("3.19.0.33", "3.19.0.34"))
end

function test_max_mpi(tc)
tc.assertEqual(gemini3d.sys.max_mpi([48,1,40], 5), 5)
tc.assertEqual(gemini3d.sys.max_mpi([48,40,1], 5),  5)
tc.assertEqual(gemini3d.sys.max_mpi([48,1,40], 6),  5)
tc.assertEqual(gemini3d.sys.max_mpi([48,40,1], 6),  5)
tc.assertEqual(gemini3d.sys.max_mpi([48,1,40], 8),  8)
tc.assertEqual(gemini3d.sys.max_mpi([48,40,1], 8),  8)
tc.assertEqual(gemini3d.sys.max_mpi([48,1,40], 28),  20)
tc.assertEqual(gemini3d.sys.max_mpi([48,1,40], 28),  20)
tc.assertEqual(gemini3d.sys.max_mpi([48,1,36], 28),  18)
end

end

end
