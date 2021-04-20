classdef TestZData < matlab.unittest.TestCase

properties
TestData
end

methods(TestMethodSetup)
function setup_env(tc)
cwd = fileparts(mfilename('fullpath'));
tc.TestData.cwd = cwd;

tc.TestData.name = "2dew_glow";
tc.TestData.data_path = fullfile(cwd, "data", tc.TestData.name);

% setup so that hdf5nc is present
run(fullfile(cwd, "../../setup.m"))

gemini3d.fileio.download_and_extract(tc.TestData.name, fullfile(cwd, "data"))

% temporary working directory
tc.TestData.outdir = tc.applyFixture(matlab.unittest.fixtures.TemporaryFolderFixture()).Folder;

end
end

methods (Test)

function test_find_config(tc)
tc.verifyEmpty(gemini3d.find.config(""))
tc.verifyTrue(endsWith(gemini3d.find.config(tc.TestData.data_path), fullfile(tc.TestData.name, "inputs", "config.nml")))
end

function test_find_simsize(tc)
tc.verifyEmpty(gemini3d.find.simsize(""))
tc.verifyTrue(endsWith(gemini3d.find.simsize(tc.TestData.data_path), fullfile(tc.TestData.name, "inputs")))
end

function test_read_config(tc)
tc.verifyEmpty(gemini3d.read.config(""))
cfg = gemini3d.read.config(tc.TestData.data_path);
tc.verifyEqual(cfg.ymd, [2013,2,20])
end

function test_get_mpi_count(tc)
import gemini3d.sys.get_mpi_count
tc.verifyEqual(get_mpi_count(""),1)
C = gemini3d.sys.get_cpu_count();
Cm = get_mpi_count(tc.TestData.data_path);
tc.verifyTrue(Cm >= 1 && Cm <= C)
end

function test_readgrid(tc)
tc.verifyEmpty(gemini3d.read.grid(""))

xg = gemini3d.read.grid(tc.TestData.data_path);
tc.verifySize(xg.x1, [xg.lx(1) + 4, 1])
end

function test_read_frame_standalone_file(tc)
tc.applyFixture(matlab.unittest.fixtures.WorkingFolderFixture)

copyfile(fullfile(tc.TestData.data_path, "20130220_18000.000000.h5"), pwd)

lxs = gemini3d.simsize(tc.TestData.data_path);

dat = gemini3d.read.frame("20130220_18000.000000.h5", "vars", "ne");
tc.assertEqual(dat.lxs, double(lxs))
tc.verifyEqual(dat.lxs, size(dat.ns, 1:3))
tc.verifyEqual([dat.lxs(1), dat.lxs(2)], size(dat.ne))
tc.verifyEqual(dat.time, datetime(2013,2,20,5,0,0))
end

function test_read_frame_filename(tc)
dat = gemini3d.read.frame(fullfile(tc.TestData.data_path, "20130220_18000.000000.h5"), "vars", "ne");

lxs = gemini3d.simsize(tc.TestData.data_path);
tc.assertEqual(dat.lxs, double(lxs))

tc.verifyEqual(dat.lxs, size(dat.ns, 1:3))
tc.verifyEqual([dat.lxs(1), dat.lxs(2)], size(dat.ne))
tc.verifyEqual(dat.time, datetime(2013,2,20,5,0,0))
end

function test_read_frame_folder_datetime(tc)
dat = gemini3d.read.frame(fullfile(tc.TestData.data_path), "time", datetime(2013,2,20,5,0,0), "vars", "ne");

lxs = gemini3d.simsize(tc.TestData.data_path);
tc.assertEqual(dat.lxs, double(lxs))

tc.verifyEqual(dat.lxs, size(dat.ns, 1:3))
tc.verifyEqual([dat.lxs(1), dat.lxs(2)], size(dat.ne))
tc.verifyEqual(dat.time, datetime(2013,2,20,5,0,0))
end

end

end
