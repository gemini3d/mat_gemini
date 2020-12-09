function compare_output(tc, outdir, refdir, tol)
arguments
  tc (1,1) matlab.unittest.TestCase
  outdir (1,1) string
  refdir (1,1) string
  tol (1,1) struct
end

tc.assertFalse(gemini3d.fileio.samepath(outdir, refdir), outdir + " and " + refdir + " are the same folder.")

%% READ IN THE SIMULATION INFORMATION
params = gemini3d.read.config(outdir);

lxs = gemini3d.simsize(outdir);
lxs_ref = gemini3d.simsize(refdir);
tc.assertNotEmpty(lxs, outdir + " does not contain Gemini3D simulation data")
tc.assertNotEmpty(lxs_ref, refdir + " does not contain Gemini3D simulation data")

tc.verifyEqual(lxs, lxs_ref, ['ref dims ', int2str(lxs_ref), ' != this sim dims ', int2str(lxs)])

disp(['sim grid dimensions: ',num2str(lxs)])

Nt = length(params.times);
tc.assertGreaterThan(Nt, 0, "simulation has zero duration")

for i = 1:Nt
  out = gemini3d.loadframe(outdir, "time", params.times(i));
  tc.assertNotEmpty(out, outdir + " does not contain output data")

  ref = gemini3d.loadframe(refdir, "time", params.times(i));

  st = datestr(params.times(i));

  tc.verifyEqual(out.ne, ref.ne, 'RelTol', tol.rtolN, 'AbsTol', tol.atolN, "Ne " + st)

  % tc.verifyEqual(out.v1, ref.v1, 'RelTol', tol.rtolV, 'AbsTol', tol.atolV, "V1 " + st)

  tc.verifyEqual(out.v2, ref.v2, 'RelTol', tol.rtolV, 'AbsTol', tol.atolV, "V2 " + st)
  tc.verifyEqual(out.v3, ref.v3, 'RelTol', tol.rtolV, 'AbsTol', tol.atolV, "V3 " + st)

  % tc.verifyEqual(out.Ti, ref.Ti, 'RelTol', tol.rtolT, 'AbsTol', tol.atolT, "Ti " + st)

  tc.verifyEqual(out.Te, ref.Te, 'RelTol', tol.rtolT, 'AbsTol', tol.atolT, "Te " + st)

  tc.verifyEqual(out.J1, ref.J1, 'RelTol', tol.rtolJ, 'AbsTol', tol.atolJ, "J1 " + st)
  tc.verifyEqual(out.J2, ref.J2, 'RelTol', tol.rtolJ, 'AbsTol', tol.atolJ, "J2 " + st)
  tc.verifyEqual(out.J3, ref.J3, 'RelTol', tol.rtolJ, 'AbsTol', tol.atolJ, "J3 " + st)

  %% ensure time steps have unique output (earth always rotating...)
  if i > 1
    tc.verifyNotEqual(Ne, out.ne, "Ne " + st + " too similar to prior step")
    % tc.verifyNotEqual(v1, out.v1, "V1 " + st + " too similar to prior step")
    tc.verifyNotEqual(v2, out.v2, "V2 " + st + " too similar to prior step")
    tc.verifyNotEqual(v3, out.v3, "V3 " + st + " too similar to prior step")
  end
  if i == 3
   % tc.verifyNotEqual(Ti, out.Ti, "Ti " + st + " too similar to prior step")
    tc.verifyNotEqual(Te, out.Te, "Te " + st + " too similar to prior step")
  end
  if i == 2
    tc.verifyNotEqual(J1, out.J1, "J1 " + st + " too similar to prior step")
    tc.verifyNotEqual(J2, out.J2, "J2 " + st + " too similar to prior step")
    tc.verifyNotEqual(J3, out.J3, "J3 " + st + " too similar to prior step")
  end

  Ne = out.ne;
  % v1=out.v1;
  v2 = out.v2;
  v3 = out.v3;
  % Ti=out.Ti;
  Te = out.Te;
  J1 = out.J1;
  J2 = out.J2;
  J3 = out.J3;

end % for

disp("OK: Gemini output comparison of " + int2str(Nt) + " time steps.")

end % function compare_output
