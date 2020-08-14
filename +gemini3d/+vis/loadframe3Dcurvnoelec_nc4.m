function dat = loadframe3Dcurvnoelec_nc4(filename)
%% READ IN SIMULATION DATA WITH NO ELECTRODYNAMIC PARAMS SUCH AS FROM AN INPUT FILE
import gemini3d.fileio.*

narginchk(1,1)
%% SIMULATIONS RESULTS
dat.filename = filename;

try
  dat.ns = ncread(filename, 'nsall');
catch
  dat.ns = ncread(filename, 'ns');
end

try
  dat.vs1 = ncread(filename, 'vs1all');
catch
  dat.vs1 = ncread(filename, 'vsx1');
end

try
  dat.Ts = ncread(filename, 'Tsall');
catch
  dat.Ts = ncread(filename, 'Ts');
end

end % function
