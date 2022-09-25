function precip(new_dir, ref_dir, opts)
arguments
  new_dir (1,1) string
  ref_dir (1,1) string
  opts.rel (1,1) {mustBePositive}
  opts.abs (1,1) {mustBePositive}
  opts.time (1,:) datetime
end

time = opts.time;
% often we reuse precipitation inputs without copying over files
for i = 1:size(time)
  ref = gemini3d.read.precip(ref_dir, time(i));
  new = gemini3d.read.precip(new_dir, time(i));

  assert(~isempty(ref), "gemini3d:compare:precip:file_not_found", "reference " + ref_dir + " does not contain precipitation data")
  assert(~isempty(new), "gemini3d:compare:precip:file_not_found", "data " + new_dir + " does not contain precipitation data")

  for k = ["E0", "Q"]
    b = ref.(k);
    a = new.(k);

    assert(all(size(a) == size(b)), "gemini3d:compare:precip:shape_error", "ref shape != data shape: " + k)

    assert(gemini3d.assert_allclose(a, b, "rtol", opts.rel, "atol", opts.abs, ...
        "err_msg", "mismatch: " + k, 'warnonly', true), ...
        "gemini3d:compare:precip:allclose_error", "mismatch " + k)
  end
end % for i

disp("OK: precipitation input " + new_dir)

end % function
