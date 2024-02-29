classdef TestGrid < matlab.unittest.TestCase

methods(TestClassSetup)

function check_stdlib(tc)
try
  gemini3d.sys.check_stdlib()
catch e
  tc.fatalAssertFail(e.message)
end
end
end

methods (Test)


function test_dipole_grid(tc)

parm = struct(lq=4, lp=6, lphi=1, dtheta=7.5, dphi=12, altmin=80e3, ...
  gridflag=1, glon=143.4, glat=42.45);

xg = gemini3d.grid.tilted_dipole(parm);

tc.verifySize(xg.e1, [parm.lq, parm.lp, parm.lphi, 3])

tc.verifyEqual(xg.e1(1,1,1,1), -0.847576545732110, RelTol=1e-6)

tc.verifyEqual(xg.glonctr, 139.56776327, RelTol=1e-6)
tc.verifyEqual(xg.glatctr, 9.51369548, RelTol=1e-6)

end

end

end
