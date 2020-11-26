function compare_efield(tc, times, E0_dir, ref_E0_dir, opts)
arguments
  tc (1,1) matlab.unittest.TestCase
  times (1,:) datetime
  E0_dir (1,1) string
  ref_E0_dir (1,1) string
  opts.rel (1,1) {mustBePositive}
  opts.abs (1,1) {mustBePositive}
end

import gemini3d.vis.load_Efield

% often we reuse Efield inputs without copying over files
for i = 1:size(times)
  ref = gemini3d.vis.load_Efield(ref_E0_dir, times(i));
  new = gemini3d.vis.load_Efield(E0_dir, times(i));

  tc.assumeNotEmpty(ref, "reference " + ref_E0_dir + " does not contain Efield data")
  tc.assumeNotEmpty(new, "data " + E0_dir + " does not contain Efield data")

  for k = ["Exit", "Eyit", "Vminx1it", "Vmaxx1it", "Vminx2ist", "Vmaxx2ist", "Vminx3ist", "Vmaxx3ist"]
    b = ref.(k);
    a = new.(k);

    reltol = cast(opts.rel, 'like', a);
    abstol = cast(opts.abs, 'like', a);

    tc.verifySize(a, size(b))

    tc.verifyEqual(a, b, 'RelTol', reltol, 'AbsTol', abstol, "mismatch: " + k)
  end
end % for i

disp("OK: Efield input " + E0_dir)

end % function
