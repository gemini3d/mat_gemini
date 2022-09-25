function compare_grid(outdir, refdir, rtol, atol)
arguments
  outdir (1,1) string
  refdir (1,1) string
  rtol (1,1) {mustBePositive}
  atol (1,1) {mustBePositive}
end

[ref, ok] = gemini3d.read.grid(refdir);
assert(ok, "reference grid " + refdir + " has bad values")

[new, ok] = gemini3d.read.grid(outdir);
assert(ok, "grid " + outdir + " has bad values")


for k = string(fieldnames(ref)).'
  if ~isnumeric(ref.(k))
    % metadata
    continue
  end

  b = ref.(k);
  a = new.(k);

  assert(all(size(a) == size(b)), k + ": ref shape " + int2str(size(b)) + " != data shape " + int2str(size(a)))

  gemini3d.assert_allclose(a, b, "rtol", rtol, "atol", atol, "err_msg", "mismatch: " + k)
end

disp("OK: simulation input grid " + outdir)

end % function
