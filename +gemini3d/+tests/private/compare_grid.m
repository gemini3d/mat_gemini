function compare_grid(tc, outdir, refdir, tol)
arguments
  tc (1,1) matlab.unittest.TestCase
  outdir (1,1) string
  refdir (1,1) string
  tol (1,1) struct
end

[ref, ok] = gemini3d.readgrid(refdir);
tc.assumeNotEmpty(ref, refdir + " does not have a Gemini3D grid")
tc.assumeTrue(ok, "reference grid " + refdir + " has bad values")

[new, ok] = gemini3d.readgrid(outdir);
tc.assumeNotEmpty(new, outdir + " does not have a Gemini3D grid")
tc.assumeTrue(ok, "grid " + outdir + " has bad values")

for k = hdf5nc.h5variables(ref.filename)
  if ~isnumeric(ref.(k))
    % metadata
    continue
  end

  b = ref.(k);
  a = new.(k);

  tc.verifySize(a, size(b), k + ": ref shape " + int2str(size(b)) + " != data shape " + int2str(size(a)))

  tc.verifyEqual(a, b, 'RelTol', tol.rtol, 'AbsTol', tol.atol, "mismatch: " + k)
end

disp("OK: simulation input grid " + outdir)

end % function
