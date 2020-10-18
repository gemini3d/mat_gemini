classdef TestZData < matlab.unittest.TestCase

properties
TestData
end

methods(TestMethodSetup)
function setup_env(tc)
cwd = fileparts(mfilename('fullpath'));
tc.TestData.cwd = cwd;

tc.TestData.name = "2dew_glow";
tc.TestData.data_path = fullfile(cwd, "data/test" + tc.TestData.name);

% setup so that hdf5nc is present
run(fullfile(cwd, "../../setup.m"))

gemini3d.fileio.download_and_extract(tc.TestData.name, fullfile(cwd, "data"))

% temporary working directory
tc.TestData.outdir = tc.applyFixture(matlab.unittest.fixtures.TemporaryFolderFixture()).Folder;

end
end

methods (Test)

function test_get_config_file(tc)
import gemini3d.fileio.get_configfile
tc.verifyEmpty(get_configfile(""))
tc.verifyTrue(endsWith(get_configfile(tc.TestData.data_path), fullfile(tc.TestData.name, "inputs", "config.nml")))
end

function test_get_simsize_path(tc)
tc.verifyEmpty(gemini3d.fileio.get_simsize_path(""))
tc.verifyTrue(endsWith(gemini3d.fileio.get_simsize_path(tc.TestData.data_path), fullfile(tc.TestData.name, "inputs")))
end

function test_read_config(tc)
tc.verifyEmpty(gemini3d.read_config(""))
cfg = gemini3d.read_config(tc.TestData.data_path);
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
tc.verifyEmpty(gemini3d.readgrid(""))

xg = gemini3d.readgrid(tc.TestData.data_path);
tc.verifySize(xg.x1, [xg.lx(1) + 4, 1])
end

function test_loadframe_standalone_file(tc)
tc.applyFixture(matlab.unittest.fixtures.WorkingFolderFixture)

copyfile(fullfile(tc.TestData.data_path, "20130220_18000.000001.h5"), pwd)

dat = gemini3d.loadframe("20130220_18000.000001.h5", "vars", "ne");
tc.verifyEqual(dat.lxs, size(dat.ns, 1:3))
tc.verifyEqual([dat.lxs(1), dat.lxs(3)], size(dat.ne))
tc.verifyEqual(dat.time, datetime(2013,2,20,5,0,0))
end

function test_loadframe_filename(tc)
dat = gemini3d.loadframe(fullfile(tc.TestData.data_path, "20130220_18000.000001.h5"), "vars", "ne");
tc.verifyEqual(dat.lxs, size(dat.ns, 1:3))
tc.verifyEqual([dat.lxs(1), dat.lxs(3)], size(dat.ne))
tc.verifyEqual(dat.time, datetime(2013,2,20,5,0,0))
end

function test_loadframe_folder_datetime(tc)
dat = gemini3d.loadframe(fullfile(tc.TestData.data_path), "time", datetime(2013,2,20,5,0,0), "vars", "ne");
tc.verifyEqual(dat.lxs, size(dat.ns, 1:3))
tc.verifyEqual([dat.lxs(1), dat.lxs(3)], size(dat.ne))
tc.verifyEqual(dat.time, datetime(2013,2,20,5,0,0))
end

end

end
