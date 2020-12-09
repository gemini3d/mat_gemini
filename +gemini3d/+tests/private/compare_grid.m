function compare_grid(tc, outdir, refdir, tol)
arguments
  tc (1,1) matlab.unittest.TestCase
  outdir (1,1) string
  refdir (1,1) string
  tol (1,1) struct
end

[ref, ok] = gemini3d.read.grid(refdir);
tc.assertNotEmpty(ref, refdir + " does not have a Gemini3D grid")
tc.assertTrue(ok, "reference grid " + refdir + " has bad values")

[new, ok] = gemini3d.read.grid(outdir);
tc.assertNotEmpty(new, outdir + " does not have a Gemini3D grid")
tc.assertTrue(ok, "grid " + outdir + " has bad values")


for k = string(fieldnames(ref)).'
  if ~isnumeric(ref.(k))
    % metadata
    continue
  end

  b = ref.(k);
  a = new.(k);

  if isfloat(a)
    reltol = cast(tol.rtol, 'like', a);
    abstol = cast(tol.atol, 'like', a);
  else
    reltol = tol.rtol;
    abstol = tol.atol;
  end
  tc.verifySize(a, size(b), k + ": ref shape " + int2str(size(b)) + " != data shape " + int2str(size(a)))

  tc.verifyEqual(a, b, 'RelTol', reltol, 'AbsTol', abstol, "mismatch: " + k)
end

disp("OK: simulation input grid " + outdir)

end % function
