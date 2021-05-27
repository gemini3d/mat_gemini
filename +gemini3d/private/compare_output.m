function compare_output(new_dir, ref_dir, tol)
arguments
  new_dir (1,1) string
  ref_dir (1,1) string
  tol (1,1) struct
end

assert(~gemini3d.fileio.samepath(new_dir, ref_dir), new_dir + " and " + ref_dir + " are the same folder.")

%% READ IN THE SIMULATION INFORMATION
params = gemini3d.read.config(new_dir, true);

lxs = gemini3d.simsize(new_dir);
lxs_ref = gemini3d.simsize(ref_dir);
assert(~isempty(lxs), new_dir + " does not contain Gemini3D simulation data")
assert(~isempty(lxs_ref), ref_dir + " does not contain Gemini3D simulation data")

assert(all(lxs == lxs_ref), "ref dims " + int2str(lxs_ref) + " != this sim dims " + int2str(lxs))

disp("sim grid dimensions: " + int2str(lxs))

Nt = length(params.times);
assert(Nt > 0, "simulation has zero duration")

bad = 0;

for i = 1:Nt
  out = gemini3d.read.frame(new_dir, "time", params.times(i));

  ref = gemini3d.read.frame(ref_dir, "time", params.times(i));

  bad = bad + compare_plot(out.ne, ref.ne, tol.rtolN, tol.atolN, "Ne", params.times(i), new_dir, ref_dir);
  bad = bad + compare_plot(out.v1, ref.v1, tol.rtolV, tol.atolV, "V1", params.times(i), new_dir, ref_dir);

  bad = bad + compare_plot(out.v2, ref.v2, tol.rtolV, tol.atolV, "V2", params.times(i), new_dir, ref_dir);
  bad = bad + compare_plot(out.v3, ref.v3, tol.rtolV, tol.atolV, "V3", params.times(i), new_dir, ref_dir);

  bad = bad + compare_plot(out.Ti, ref.Ti, tol.rtolT, tol.atolT, "Ti", params.times(i), new_dir, ref_dir);

  bad = bad + compare_plot(out.Te, ref.Te, tol.rtolT, tol.atolT, "Te", params.times(i), new_dir, ref_dir);

  bad = bad + compare_plot(out.J1, ref.J1, tol.rtolJ, tol.atolJ, "J1", params.times(i), new_dir, ref_dir);
  bad = bad + compare_plot(out.J2, ref.J2, tol.rtolJ, tol.atolJ, "J2", params.times(i), new_dir, ref_dir);
  bad = bad + compare_plot(out.J3, ref.J3, tol.rtolJ, tol.atolJ, "J3", params.times(i), new_dir, ref_dir);

  %% FIXME: omitted too similar tests for now

end % for

assert(bad==0, int2str(bad) + " mismatched variables in " + new_dir)

disp("OK: compare:output: " + int2str(Nt) + " time steps.")

end % function compare_output
