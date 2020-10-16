classdef TestZData < matlab.unittest.TestCase

properties
TestData
end

methods(TestMethodSetup)
function setup_env(tc)
cwd = fileparts(mfilename('fullpath'));
tc.TestData.cwd = cwd;

name = "2dew_glow";
tc.TestData.data_path = fullfile(cwd, "data/test" + name);

gemini3d.fileio.download_and_extract(name, fullfile(cwd, "data"))

% temporary working directory
tc.TestData.outdir = tc.applyFixture(matlab.unittest.fixtures.TemporaryFolderFixture()).Folder;

end
end

methods (Test)

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
