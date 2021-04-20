function bad = compare_plot(new, ref, rtol, atol, name, time, new_dir, ref_dir)

bad = false;

if ~gemini3d.allclose(new, ref, 'rtol', rtol, 'atol', atol)
  bad = true;
  gemini3d.plot.diff(new, ref, name, time, new_dir, ref_dir)
end

end
