classdef TestConfig < matlab.unittest.TestCase

properties
TestData
end

methods(TestClassSetup)

function config_path(tc)
tc.TestData.cwd = fileparts(mfilename("fullpath"));
tc.TestData.config = tc.TestData.cwd + "/config.nml";
end

end


methods(Test)

function test_read_namelist(tc)
s = gemini3d.read.namelist(tc.TestData.config, "expandCheck");

tc.verifyEqual(s.singlequote, "@GEMINI_CIROOT@/test123")
tc.verifyEqual(s.doublequote, "@GEMINI_CIROOT@/test321")

end

function test_find_config(tc)
tc.verifyEqual(gemini3d.find.config(tc.TestData.cwd), tc.TestData.config)
end

function test_read_config(tc)
p = gemini3d.read.config(tc.TestData.cwd);

tc.verifyEqual(p.ymd, [2013,2,20])
tc.verifyEqual(p.times(1), datetime(2013, 2, 20, 5, 0, 0))
tc.verifyEqual(p.dtprec, 5)
tc.verifyEqual(p.W0BG, 3000.0)
end

end

end
