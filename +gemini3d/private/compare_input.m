function compare_input(new_dir, ref_dir, tol)
arguments
  new_dir (1,1) string
  ref_dir (1,1) string
  tol (1,1) struct
end

import stdlib.fileio.samepath
import gemini3d.fileio.make_valid_paths

assert(~samepath(new_dir, ref_dir), new_dir + " and " + ref_dir + " are the same folder.")

%% check simulation grid
compare_grid(new_dir, ref_dir, tol.rtol, tol.atol)

%% check initial condition data
ref_params = make_valid_paths(gemini3d.read.config(ref_dir), ref_dir);
ref = gemini3d.read.frame3Dcurvnoelec(ref_params.indat_file);

new_params = make_valid_paths(gemini3d.read.config(new_dir), new_dir);
new = gemini3d.read.frame3Dcurvnoelec(new_params.indat_file);

assert(~isempty(new_params.times), "simulation input has zero duration")

gemini3d.assert_allclose(new.ns, ref.ns, "rtol", tol.rtol, "atol", tol.atolN/100, "err_msg", 'mismatch: Ns')
gemini3d.assert_allclose(new.Ts, ref.Ts, "rtol", tol.rtol, "atol", tol.atolT/100, "err_msg", 'mismatch: Ts')
gemini3d.assert_allclose(new.vs1, ref.vs1, "rtol", tol.rtol, "atol", tol.atolV/100, "err_msg", 'mismatch: vs')

%% precipitation
if isfield(new_params, 'prec_dir')
  compare_precip(new_params.prec_dir, ref_params.prec_dir, "abs", tol.atol, "rel", tol.rtol, "time", new_params.times)
end
%% Efield
if isfield(new_params, 'E0_dir')
  compare_efield(new_params.E0_dir, ref_params.E0_dir, "abs", tol.atol, "rel", tol.rtol, "time", new_params.times)
end
%% final
disp('OK: Gemini input comparison')

end
