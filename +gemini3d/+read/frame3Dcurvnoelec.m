function dat = frame3Dcurvnoelec(filename)
%% READ IN SIMULATION DATA WITH NO ELECTRODYNAMIC PARAMS SUCH AS FROM AN INPUT FILE
arguments
  filename (1,1) string
end

[~,~,ext] = fileparts(filename);

vars = ["ns", "Ts", "v1"];

switch ext
  case '.h5', dat = frame3Dcurv_hdf5(filename, vars);
  otherwise, error('gemini3d:read:frame3Dcurvnoelec:value_error', 'unknown file type %s',filename)
end

dat.filename = filename;

if ~isfield(dat, 'time')
  % keep this in case this function called directly
  dat.time = gemini3d.read.time(filename);
end

dat = curv_derived(dat, vars);
end
