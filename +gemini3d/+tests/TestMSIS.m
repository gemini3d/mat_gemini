classdef TestMSIS < matlab.unittest.TestCase

properties
  TestData
end

methods(TestMethodSetup)

function setup_grid(tc)
lx = [4, 2, 3];
[glon, alt, glat] = meshgrid(linspace(-147, -145, lx(2)), linspace(100e3, 200e3, lx(1)), linspace(65, 66, lx(3)));
xg = struct('glat', glat, 'glon', glon, 'lx', lx, 'alt', alt);

tc.TestData.xg = xg;
end

end

methods (Test)

function test_msis00_setup(tc)

cfg = struct('times', datetime(2015, 1, 2) + seconds(43200), 'f107', 100.0, 'f107a', 100.0, 'Ap', 4, 'msis_version', 0);

atmos = gemini3d.model.msis(cfg, tc.TestData.xg);

tc.verifySize(atmos, [tc.TestData.xg.lx, 7], 'MSIS setup data output shape unexpected')

tc.verifyEqual(atmos(1,2,3,4), single(185.19141), 'reltol', single(1e-5))
end

function test_msis20_setup(tc)

cfg = struct('times', datetime(2015, 1, 2) + seconds(43200), 'f107', 100.0, 'f107a', 100.0, 'Ap', 4, 'msis_version', 20);

atmos = gemini3d.model.msis(cfg, tc.TestData.xg);

tc.verifySize(atmos, [tc.TestData.xg.lx, 7], 'MSIS setup data output shape unexpected')

tc.verifyEqual(atmos(1,2,3,4), single(186.54959), 'reltol', single(1e-5))
end

end

end
