function dat = frame3Dcurvnoelec(filename)
%% READ IN SIMULATION DATA WITH NO ELECTRODYNAMIC PARAMS SUCH AS FROM AN INPUT FILE
arguments
  filename (1,1) {mustBeFile}
end

vars = ["ns", "Ts", "v1"];

dat = frame3Dcurv_hdf5(filename, vars);

dat.filename = filename;

if ~isfield(dat, 'time')
  % keep this in case this function called directly
  dat.time = gemini3d.read.time(filename);
end

dat = curv_derived(dat, vars);
end
