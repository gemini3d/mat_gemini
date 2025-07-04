classdef TestMSIS < matlab.unittest.TestCase

properties
xg
end

methods(TestClassSetup)

function check_stdlib(tc)
try
  gemini3d.sys.check_stdlib()
catch e
  tc.fatalAssertFail(e.message)
end
end

function setup_grid(tc)
lx = [4, 2, 3];
[glon, alt, glat] = meshgrid(linspace(-147, -145, lx(2)), linspace(100e3, 200e3, lx(1)), linspace(65, 66, lx(3)));
tc.xg = struct(glat=glat, glon=glon, lx=lx, alt=alt);
end

end

methods (Test, TestTags="msis")

function test_msis00_setup(tc)

inputs_dir = tc.createTemporaryFolder();

cfg = struct(times=datetime(2015, 1, 2, 0, 0, 43200), f107=100.0, f107a=100.0, Ap=4, ...
  msis_version=0, indat_size=fullfile(inputs_dir, "simsize.h5"));

try
  atmos = gemini3d.model.msis(cfg, tc.xg);
catch err
  catcher(err, tc)
end

tc.verifySize(atmos.Tn, tc.xg.lx, 'MSIS setup data output shape unexpected')

tc.verifyEqual(atmos.Tn(1,2,3), single(185.5902), RelTol=single(1e-5))
end


function test_msis00_not_exist_relative(tc)

inputs_dir = tempname;

cfg = struct( ...
  times=datetime(2015,1,2,0,0,43200), ...
  f107=100.0, ...
  f107a=100.0, ...
  Ap=4, ...
  msis_version=0, ...
  indat_size=inputs_dir + "/simsize.h5");

try
  atmos = gemini3d.model.msis(cfg, tc.xg);
catch err
  catcher(err, tc)
end

tc.verifySize(atmos.Tn, tc.xg.lx, 'MSIS setup data output shape unexpected')

tc.verifyEqual(atmos.Tn(1,2,3), single(185.5902), RelTol=single(1e-5))
end


function test_msis2_setup(tc)

inputs_dir = tc.createTemporaryFolder();

cfg = struct(times=datetime(2015, 1, 2, 0, 0, 43200), f107=100.0, f107a=100.0, Ap=4, ...
  msis_version=21, indat_size=inputs_dir + "/simsize.h5");

try
  atmos = gemini3d.model.msis(cfg, tc.xg);
catch err
  catcher(err, tc)
end
tc.verifySize(atmos.Tn, tc.xg.lx, 'MSIS setup data output shape unexpected')

tc.verifyEqual(atmos.Tn(1,2,3), single(189.7185), RelTol=single(1e-5))
end

end

end
