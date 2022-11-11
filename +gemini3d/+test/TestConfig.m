classdef TestConfig < matlab.unittest.TestCase

properties
TestData
end

methods(TestMethodSetup)

function config_path(tc)
tc.TestData.cwd = fileparts(mfilename("fullpath"));
end

end

methods(Test)

function test_find_config(tc)
tc.verifyEqual(gemini3d.find.config(tc.TestData.cwd), fullfile(tc.TestData.cwd, "config.nml"))
end

function test_read_config(tc)
cfg = gemini3d.read.config(tc.TestData.cwd);
tc.verifyEqual(cfg.ymd, [2013,2,20])
end

end

end