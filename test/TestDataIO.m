classdef TestDataIO < matlab.unittest.TestCase

properties
TestData
end

methods(TestClassSetup)

function check_stdlib(tc)
try
  gemini3d.sys.check_stdlib()
catch e
  tc.fatalAssertFail(e.message)
end
end


function setup_env(tc)

cwd = fileparts(mfilename('fullpath'));
tc.TestData.cwd = cwd;
dpath = cwd + "/data";

tc.TestData.name = "mini2dew_glow";
tc.TestData.data_path = fullfile(dpath, tc.TestData.name);

% don't import so it sets up first
try
  gemini3d.fileio.download_and_extract(tc.TestData.name, dpath)
catch e
  catcher(e, tc)
end

tc.TestData.outdir = tc.createTemporaryFolder();

end
end

methods (Test)

function test_find_simsize(tc)
tc.verifyTrue(endsWith(gemini3d.find.simsize(tc.TestData.data_path), tc.TestData.name + "/inputs/simsize.h5"))
end

function test_get_mpi_count(tc)
import gemini3d.sys.get_mpi_count
C = gemini3d.sys.get_cpu_count();
Cm = get_mpi_count(tc.TestData.data_path);
tc.verifyTrue(Cm >= 1 && Cm <= C)
end

function test_readgrid(tc)
xg = gemini3d.read.grid(tc.TestData.data_path);
tc.verifySize(xg.x1, [xg.lx(1) + 4, 1])
end

function test_read_frame_standalone_file(tc)
tc.applyFixture(matlab.unittest.fixtures.WorkingFolderFixture)

copyfile(tc.TestData.data_path + "/20130220_18000.000000.h5", pwd())

lxs = gemini3d.simsize(tc.TestData.data_path);

dat = gemini3d.read.frame("20130220_18000.000000.h5", vars="ne");
tc.assertEqual(dat.lxs, double(lxs))
tc.verifyEqual(dat.lxs, size(dat.ns, 1:3))
tc.verifyEqual([dat.lxs(1), dat.lxs(2)], size(dat.ne))
tc.verifyEqual(dat.time, datetime(2013,2,20,5,0,0))
end

function test_read_frame_filename(tc)
dat = gemini3d.read.frame(tc.TestData.data_path + "/20130220_18000.000000.h5", vars="ne");

lxs = gemini3d.simsize(tc.TestData.data_path);
tc.assertEqual(dat.lxs, double(lxs))

tc.verifyEqual(dat.lxs, size(dat.ns, 1:3))
tc.verifyEqual([dat.lxs(1), dat.lxs(2)], size(dat.ne))
tc.verifyEqual(dat.time, datetime(2013,2,20,5,0,0))
end

function test_read_frame_folder_datetime(tc)
dat = gemini3d.read.frame(tc.TestData.data_path, time=datetime(2013,2,20,5,0,0), vars="ne");

lxs = gemini3d.simsize(tc.TestData.data_path);
tc.assertEqual(dat.lxs, double(lxs))

tc.verifyEqual(dat.lxs, size(dat.ns, 1:3))
tc.verifyEqual([dat.lxs(1), dat.lxs(2)], size(dat.ne))
tc.verifyEqual(dat.time, datetime(2013,2,20,5,0,0))
end

end

end
