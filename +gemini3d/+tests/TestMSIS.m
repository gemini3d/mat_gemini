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

inputs_dir =  tc.applyFixture(matlab.unittest.fixtures.TemporaryFolderFixture(PreservingOnFailure=true)).Folder;

cfg = struct('times', datetime(2015, 1, 2, 0, 0, 43200), 'f107', 100.0, 'f107a', 100.0, 'Ap', 4, ...
  'msis_version', 0, 'indat_size', fullfile(inputs_dir, "simsize.h5"));

try
  atmos = gemini3d.model.msis(cfg, tc.TestData.xg);
catch e
  if contains(e.message, "HDF5 library version mismatched error")
    tc.assumeFail("HDF5 shared library conflict Matlab <=> system")
  elseif contains(e.message, "GLIBCXX")
    tc.assumeFail("conflict in libstdc++ Matlab <=> system")
  else
    rethrow(e)
  end
end

tc.verifySize(atmos.Tn, tc.TestData.xg.lx, 'MSIS setup data output shape unexpected')

tc.verifyEqual(atmos.Tn(1,2,3), single(185.5902), RelTol=single(1e-5))
end


function test_msis00_not_exist_relative(tc)

inputs_dir =  'not-exist';

cfg = struct('times', datetime(2015, 1, 2, 0, 0, 43200), 'f107', 100.0, 'f107a', 100.0, 'Ap', 4, ...
  'msis_version', 0, 'indat_size', fullfile(inputs_dir, "simsize.h5"));

try
  atmos = gemini3d.model.msis(cfg, tc.TestData.xg);
catch e
  if contains(e.message, "HDF5 library version mismatched error")
    tc.assumeFail("HDF5 shared library conflict Matlab <=> system")
  elseif contains(e.message, "GLIBCXX")
    tc.assumeFail("conflict in libstdc++ Matlab <=> system")
  else
    rethrow(e)
  end
end

tc.verifySize(atmos.Tn, tc.TestData.xg.lx, 'MSIS setup data output shape unexpected')

tc.verifyEqual(atmos.Tn(1,2,3), single(185.5902), RelTol=single(1e-5))
end


function test_msis20_setup(tc)

inputs_dir =  tc.applyFixture(matlab.unittest.fixtures.TemporaryFolderFixture(PreservingOnFailure=true)).Folder;

cfg = struct('times', datetime(2015, 1, 2, 0, 0, 43200), 'f107', 100.0, 'f107a', 100.0, 'Ap', 4, ...
  'msis_version', 20, 'indat_size', fullfile(inputs_dir, "simsize.h5"));

try
  atmos = gemini3d.model.msis(cfg, tc.TestData.xg);
catch e
  if contains(e.message, "msis20.parm not found")
    tc.assumeFail("MSIS 2 not enabled")
  elseif contains(e.message, "HDF5 library version mismatched error")
    tc.assumeFail("HDF5 shared library conflict Matlab <=> system")
  elseif contains(e.message, "GLIBCXX")
    tc.assumeFail("conflict in libstdc++ Matlab <=> system")
  else
    rethrow(e)
  end
end
tc.verifySize(atmos.Tn, tc.TestData.xg.lx, 'MSIS setup data output shape unexpected')

tc.verifyEqual(atmos.Tn(1,2,3), single(189.7185), RelTol=single(1e-5))
end

end

end
