function compare_efield(new_dir, ref_dir, opts)
arguments
  new_dir (1,1) string
  ref_dir (1,1) string
  opts.rel (1,1) {mustBePositive}
  opts.abs (1,1) {mustBePositive}
  opts.time (1,:) datetime = datetime.empty
end

if isempty(opts.time)
  cfg_dir = fullfile(new_dir, "..");
  cfg = gemini3d.read.config(cfg_dir);
  assert(~isempty(cfg), "config.nml not in " + cfg_dir)
  time = cfg.times(1):seconds(cfg.dtE0):cfg.times(end);
else
  time = opts.time;
end

% often we reuse Efield inputs without copying over files
for i = 1:size(time)
  ref = gemini3d.read.Efield(ref_dir, time(i));
  new = gemini3d.read.Efield(new_dir, time(i));

  assert(~isempty(ref), "reference " + ref_dir + " does not contain Efield data")
  assert(~isempty(new), "data " + new_dir + " does not contain Efield data")

  for k = ["Exit", "Eyit", "Vminx1it", "Vmaxx1it", "Vminx2ist", "Vmaxx2ist", "Vminx3ist", "Vmaxx3ist"]
    b = ref.(k);
    a = new.(k);

    gemini3d.assert_allclose(a, b, 'rtol', opts.rel, 'atol', opts.abs, "err_msg", "mismatch: " + k)
  end
end % for i

disp("OK: Efield input " + new_dir)

end % function
