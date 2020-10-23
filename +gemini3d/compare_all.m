function compare_all(outdir, refdir, opts)
% compare entire output directory data files, and input files
%
% absolute and relative tolerance account for slight IEEE-754 based differences,
% including non-associative, non-commutative floating-point arithmetic.
% these parameters are a bit arbitrary.

% per MZ Oct 17, 2018:
% Ti,Te=1 K
% ne=1e6 m-3
% vi,v2,v3=1 m/s
% J1,J2,J3 = 1e-9

% MZ wants to change what we consider signficant...
% Ti,Te=5 K
% ne=1e7 m-3
% vi,v2,v3=2 m/s
% J1,J2,J3 = 1e-9

arguments
  outdir (1,1) string
  refdir (1,1) string
  opts.only (1,:) string = string.empty
  opts.file_format = string.empty
end

tol.rtol = 1e-5;
tol.rtolN = 1e-5;
tol.rtolT = 1e-5;
tol.rtolJ = 1e-5;
tol.rtolV = 1e-5;
tol.atol = 1e-8;
tol.atolN = 1e9;
tol.atolT = 100;
tol.atolJ = 1e-7;
tol.atolV = 50;

outdir = gemini3d.fileio.absolute_path(outdir);
refdir = gemini3d.fileio.absolute_path(refdir);

%% check that paths not the same
if outdir == refdir
  error('compare_all:value_error', '%s and %s directories are the same', outdir, refdir)
end
%% times

%% check output dirs
out_ok = 0;
if isempty(opts.only) || any(opts.only == "out")
  out_ok = compare_output(outdir, refdir, tol);
end
%% check input dirs
in_ok = 0;
if isempty(opts.only) || any(opts.only == "in")
  in_ok = compare_input(outdir, refdir, tol, opts.file_format);
end
%% finish up
if out_ok ~= 0 || in_ok ~= 0
  error('compare_all:value_error', '%d output, %d input: compare errors', out_ok, in_ok)
end

end % function


function ok = compare_output(outdir, refdir, tol)
import gemini3d.assert_allclose

%% READ IN THE SIMULATION INFORMATION
params = gemini3d.read_config(outdir);

lxs = gemini3d.simsize(outdir);
lxs_ref = gemini3d.simsize(refdir);

if isempty(lxs)
  error("compare_all:file_not_found", "%s does not contain Gemini3D simulation data", outdir)
end
if isempty(lxs_ref)
  error("compare_all:file_not_found", "%s does not contain Gemini3D simulation data", refdir)
end

if any(lxs ~= lxs_ref)
  error('compare_all:value_error', ['ref dims ', int2str(lxs_ref), ' != this sim dims ', int2str(lxs)])
end

disp(['sim grid dimensions: ',num2str(lxs)])

Nt = length(params.times);

ok = 0;

for i = 1:Nt
  out = gemini3d.loadframe(outdir, "time", params.times(i));
  ref = gemini3d.loadframe(refdir, "time", params.times(i));

  st = datestr(params.times(i));

  ok = ok + ~assert_allclose(out.ne,ref.ne,tol.rtolN,tol.atolN,['Ne ',st], true);

  % ok = ok + ~assert_allclose(out.v1,ref.v1,tol.rtolV,tol.atolV,['V1 ', st], true);

  ok = ok + ~assert_allclose(out.v2,ref.v2,tol.rtolV,tol.atolV,['V2 ', st], true);
  ok = ok + ~assert_allclose(out.v3,ref.v3,tol.rtolV,tol.atolV,['V3 ', st], true);

  % ok = ok + ~assert_allclose(out.Ti,ref.Ti,tol.rtolT,tol.atolT,['Ti ', st], true);

  ok = ok + ~assert_allclose(out.Te,ref.Te,tol.rtolT,tol.atolT,['Te ', st], true);

  ok = ok + ~assert_allclose(out.J1,ref.J1,tol.rtolJ,tol.atolJ,['J1 ', st], true);
  ok = ok + ~assert_allclose(out.J2,ref.J2,tol.rtolJ,tol.atolJ,['J2 ', st], true);
  ok = ok + ~assert_allclose(out.J3,ref.J3,tol.rtolJ,tol.atolJ,['J3 ', st], true);

  %% assert time steps have unique output (earth always rotating...)
  if i > 1
    ok = ok + ~assert_allclose(Ne,out.ne,tol.rtol,tol.atol,['Ne ', st,' too similar to prior step'],true, true);
    %ok = ok + ~assert_allclose(v1,out.v1,tol.rtol,tol.atol,['V1 ', st,' too similar to prior step'],true, true);
    ok = ok + ~assert_allclose(v2,out.v2,tol.rtol,tol.atol,['V2 ', st,' too similar to prior step'],true, true);
    ok = ok + ~assert_allclose(v3,out.v3,tol.rtol,tol.atol,['V3 ', st,' too similar to prior step'],true, true);
  end
  if i == 3
   %ok = ok + ~assert_allclose(Ti,out.Ti,tol.rtol,tol.atol,['Ti ', st,' too similar to prior step'],true, true);
    ok = ok + ~assert_allclose(Te,out.Te,tol.rtol,tol.atol,['Te ', st,' too similar to prior step'],true, true);
  end
  if i == 2
    ok = ok + ~assert_allclose(J1,out.J1,tol.rtol,tol.atol,['J1 ', st,' too similar to prior step'],true,true, true);
    ok = ok + ~assert_allclose(J2,out.J2,tol.rtol,tol.atol,['J2 ', st,' too similar to prior step'],true,true, true);
    ok = ok + ~assert_allclose(J3,out.J3,tol.rtol,tol.atol,['J3 ', st,' too similar to prior step'],true,true, true);
  end

  Ne = out.ne;
  % v1=out.v1;
  v2 = out.v2;
  v3 = out.v3;
  % Ti=out.Ti;
  Te = out.Te;
  J1 = out.J1;
  J2 = out.J2;
  J3 = out.J3;

end % for

if ok == 0
  fprintf('OK: Gemini output comparison of %d time steps.\n', Nt)
end

end % function compare_output

function errs = compare_input(outdir, refdir, tol, file_format)
import gemini3d.assert_allclose
import gemini3d.fileio.make_valid_paths

%% check simulation grid
compare_grid(outdir, refdir, tol)

%% check initial condition data
ref_params = make_valid_paths(gemini3d.read_config(refdir), refdir);
ref = gemini3d.vis.loadframe3Dcurvnoelec(ref_params.indat_file);

new_params = make_valid_paths(gemini3d.read_config(outdir), outdir, file_format);
new = gemini3d.vis.loadframe3Dcurvnoelec(new_params.indat_file);

errs = 0;

errs = errs + ~assert_allclose(new.ns, ref.ns, tol.rtol, tol.atolN/100, 'Ns', true);
errs = errs + ~assert_allclose(new.Ts, ref.Ts, tol.rtol, tol.atolT/100, 'Ts', true);
errs = errs + ~assert_allclose(new.vs1, ref.vs1, tol.rtol, tol.atolV/100, 'vs', true);

%% precipitation
if isfield(new_params, 'prec_dir')
  errs = errs + compare_precip(new_params.times, new_params.prec_dir, ref_params.prec_dir, tol);
end
%% Efield
if isfield(new_params, 'E0_dir')
  errs = errs + compare_efield(new_params.times, new_params.E0_dir, ref_params.E0_dir, tol);
end
%% final

if errs == 0
  disp('OK: Gemini input comparison')
end

end % function compare_input


function compare_grid(outdir, refdir, tol)

[ref, ok] = gemini3d.readgrid(refdir);
if isempty(ref)
  error("gemini3d:compare_all:compare_grid", "%s does not have a Gemini3D grid", refdir)
end
assert(ok, "reference grid " + refdir + " has bad values")

[new, ok] = gemini3d.readgrid(outdir);
if isempty(new)
  error("gemini3d:compare_all:compare_grid", "%s does not have a Gemini3D grid", outdir)
end
assert(ok, "grid " + outdir + " has bad values")

errs = 0;
for k = hdf5nc.h5variables(ref.filename)
  if ~isnumeric(ref.(k))
    % metadata
    continue
  end

  b = ref.(k);
  a = new.(k);

  if any(size(a) ~= size(b))
    error("compare_all:value_error", k + ": ref shape " + int2str(size(b)) + " != data shape " + int2str(size(a)))
  end

  if ~gemini3d.allclose(a, b, 'rtol', tol.rtol, 'atol', tol.atol)
    errs = errs + 1;
    warning("mismatch: %s\n", k)
  end
end

if errs == 0
  disp("OK: simulation input grid " + outdir)
end


end % function


function errs = compare_precip(times, prec_dir, ref_prec_dir, tol)

errs = 0;

% often we reuse precipitation inputs without copying over files
for i = 1:size(times)
  ref = gemini3d.vis.load_precip(ref_prec_dir, times(i));
  new = gemini3d.vis.load_precip(prec_dir, times(i));

  for k = ["E0", "Q"]
    b = ref.(k);
    a = new.(k);

    if any(size(a) ~= size(b))
      error("compare_all:value_error", "%s: ref shape {b.shape} != data shape {a.shape}", k)
    end

    if ~ gemini3d.allclose(a, b, 'rtol', tol.rtol, 'atol', tol.atol)
      errs = errs + 1;
      warning("mismatch: %s %s\n", k, datestr(times(i)))
    end
  end
end % for i

if errs == 0
  disp("OK: precipitation input " + prec_dir)
end

end % function


function errs = compare_efield(times, E0_dir, ref_E0_dir, tol)
import gemini3d.vis.load_Efield

errs = 0;

% often we reuse Efield inputs without copying over files
for i = 1:size(times)
  ref = load_Efield(ref_E0_dir, times(i));
  new = load_Efield(E0_dir, times(i));


  for k = ["Exit", "Eyit", "Vminx1it", "Vmaxx1it", "Vminx2ist", "Vmaxx2ist", "Vminx3ist", "Vmaxx3ist"]
    b = ref.(k);
    a = new.(k);

    if any(size(a) ~= size(b))
      error("compare_all:value_error", "%s: ref shape {b.shape} != data shape {a.shape}", k{:})
    end

    if ~gemini3d.allclose(a, b, 'rtol', tol.rtol, 'atol', tol.atol)
      errs = errs + 1;
      warning("mismatch: %s %s\n", k{:}, datestr(times(i)))
    end
  end
end % for i

if errs == 0
  disp("OK: Efield input " + E0_dir)
end

end % function

% Copyright 2020 Michael Hirsch, Ph.D.

% Licensed under the Apache License, Version 2.0 (the "License");
% you may not use this file except in compliance with the License.
% You may obtain a copy of the License at

%     http://www.apache.org/licenses/LICENSE-2.0

% Unless required by applicable law or agreed to in writing, software
% distributed under the License is distributed on an "AS IS" BASIS,
% WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
% See the License for the specific language governing permissions and
% limitations under the License.
