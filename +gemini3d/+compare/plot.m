function bad = plot(new, ref, rtol, atol, name, time, new_dir, ref_dir)

bad = ~gemini3d.allclose(new, ref, rtol=rtol, atol=atol);

if bad
  gemini3d.plot.diff(new, ref, name, time, new_dir, ref_dir)
end

end
