function dat = frame3Dcurvnoelec_raw(filename)
%% READ IN SIMULATION DATA WITH NO ELECTRODYNAMIC PARAMS SUCH AS FROM AN INPUT FILE
arguments
  filename (1,1) string
end

%% SIMULATION SIZE
lsp=7;
lxs = gemini3d.simsize(filename);
%% SIMULATION RESULTS
fid = fopen(filename, 'r');

gemini3d.read.time(fid);

dat.ns = read4D(fid, lsp, lxs);
dat.vs1 = read4D(fid, lsp, lxs);
dat.Ts = read4D(fid, lsp, lxs);

fclose(fid);

end % function
