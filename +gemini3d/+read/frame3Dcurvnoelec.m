function dat = frame3Dcurvnoelec(filename)
%% READ IN SIMULATION DATA WITH NO ELECTRODYNAMIC PARAMS SUCH AS FROM AN INPUT FILE
arguments
  filename (1,1) string
end

[~,~,ext] = fileparts(filename);
assert(isfile(filename), 'not a file: %s', filename)

vars = ["ns", "Ts", "v1"];

switch ext
  case '.h5', dat = frame3Dcurv_hdf5(filename, vars);
  case '.nc', dat = frame3Dcurv_nc4(filename, vars);
  case '.dat', dat = frame3Dcurvnoelec_raw(filename);
  otherwise, error('frame3Dcurvnoelec:not_implemented', 'unknown file type %s',filename)
end

dat.filename = filename;

dat = curv_squeeze(dat, vars);
end
