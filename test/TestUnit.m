classdef TestUnit < matlab.unittest.TestCase

properties
  TestData
end

methods(TestClassSetup)

function setup_env(tc)
tc.assumeTrue(~isMATLABReleaseOlderThan('R2023a'))
import matlab.unittest.fixtures.EnvironmentVariableFixture

tc.TestData.outdir = tc.applyFixture(matlab.unittest.fixtures.TemporaryFolderFixture()).Folder;

fixture = EnvironmentVariableFixture("GEMCI_ROOT", tc.TestData.outdir);
tc.applyFixture(fixture)

end
end

methods (Test)


function test_nml_gemini_envvar(tc)
tc.assumeTrue(~isMATLABReleaseOlderThan('R2023a'))
import matlab.unittest.fixtures.EnvironmentVariableFixture

fixture = EnvironmentVariableFixture("GEMCI_ROOT", tc.TestData.outdir);
tc.applyFixture(fixture)

out = gemini3d.fileio.expand_envvar("@GEMCI_ROOT@/foo");

tc.verifyEqual(out, fullfile(tc.TestData.outdir, "foo"))


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
