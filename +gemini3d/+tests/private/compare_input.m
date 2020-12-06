function compare_input(tc, outdir, refdir, tol, file_format)
arguments
  tc (1,1) matlab.unittest.TestCase
  outdir (1,1) string
  refdir (1,1) string
  tol (1,1) struct
  file_format string = string.empty
end

tc.assertFalse(gemini3d.fileio.samepath(outdir, refdir), outdir + " and " + refdir + " are the same folder.")

%% check simulation grid
compare_grid(tc, outdir, refdir, tol)

%% check initial condition data
ref_params = gemini3d.fileio.make_valid_paths(gemini3d.read_config(refdir), refdir);
ref = gemini3d.vis.loadframe3Dcurvnoelec(ref_params.indat_file);

new_params = gemini3d.fileio.make_valid_paths(gemini3d.read_config(outdir), outdir, file_format);
new = gemini3d.vis.loadframe3Dcurvnoelec(new_params.indat_file);

tc.assertGreaterThan(length(new_params.times), 0, "simulation input has zero duration")

reltol = cast(tol.rtol, 'like', new.ns);

tc.verifyEqual(new.ns, ref.ns, 'RelTol', reltol, 'AbsTol', cast(tol.atolN, 'like', new.ns)/100, 'mismatch: Ns')
tc.verifyEqual(new.Ts, ref.Ts, 'RelTol', reltol, 'AbsTol', cast(tol.atolT, 'like', new.Ts)/100, 'mismatch: Ts')
tc.verifyEqual(new.vs1, ref.vs1, 'RelTol', reltol, 'AbsTol', cast(tol.atolV, 'like', new.vs1)/100, 'mismatch: vs')

%% precipitation
if isfield(new_params, 'prec_dir')
  compare_precip(tc, new_params.times, new_params.prec_dir, ref_params.prec_dir, 'abs', tol.atol, 'rel', tol.rtol)
end
%% Efield
if isfield(new_params, 'E0_dir')
  compare_efield(tc, new_params.times, new_params.E0_dir, ref_params.E0_dir, 'abs', tol.atol, 'rel', tol.rtol)
end
%% final
disp('OK: Gemini input comparison')

end
