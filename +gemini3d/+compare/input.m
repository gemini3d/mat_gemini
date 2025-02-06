function input(new_dir, ref_dir, tol)
arguments
  new_dir (1,1) string
  ref_dir (1,1) string
  tol (1,1) struct
end

assert(~stdlib.samepath(new_dir, ref_dir), "gemini3d:compare:samepath_error", new_dir + " and " + ref_dir + " are the same folder.")

%% check simulation grid
gemini3d.compare.grid(new_dir, ref_dir, tol.rtol, tol.atol)

%% check initial condition data
ref_params = gemini3d.fileio.make_valid_paths(gemini3d.read.config(ref_dir), ref_dir);
ref = gemini3d.read.frame3Dcurvnoelec(ref_params.indat_file);

new_params = gemini3d.fileio.make_valid_paths(gemini3d.read.config(new_dir), new_dir);
new = gemini3d.read.frame3Dcurvnoelec(new_params.indat_file);

assert(~isempty(new_params.times), "gemini3d:compare:input:value_error", "simulation input has zero duration")

assert(gemini3d.assert_allclose(new.ns, ref.ns, ...
  rtol=tol.rtolN, atol=tol.atolN, err_msg='mismatch: Ns', warnonly=true), ...
  "gemini3d:compare:input:allclose_error", "compare.input: Ns")

assert(gemini3d.assert_allclose(new.Ts, ref.Ts, ...
  rtol=tol.rtolT, atol=tol.atolT, err_msg='mismatch: Ts', warnonly=true), ...
  "gemini3d:compare:input:allclose_error", "compare.input: Ts")

assert(gemini3d.assert_allclose(new.vs1, ref.vs1, ...
  rtol=tol.rtolV, atol=tol.atolV, err_msg='mismatch: vs', warnonly=true), ...
  "gemini3d:compare:input:allclose_error", "compare.input: vs")

%% precipitation
if isfield(new_params, 'prec_dir')
  gemini3d.compare.precip(new_params.prec_dir, ref_params.prec_dir, abs=tol.atol, rel= tol.rtol, time=new_params.times)
end
%% Efield
if isfield(new_params, 'E0_dir')
  gemini3d.compare.efield(new_params.E0_dir, ref_params.E0_dir, abs=tol.atol, rel= tol.rtol, time=new_params.times)
end
%% final
disp('OK: Gemini input comparison')

end
