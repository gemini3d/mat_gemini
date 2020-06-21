function dat = loadframe3Dcurvnoelec_nc4(filename)
%% READ IN SIMULATION DATA WITH NO ELECTRODYNAMIC PARAMS SUCH AS FROM AN INPUT FILE
narginchk(1,1)
%% SIMULATIONS RESULTS
assert(is_file(filename), [filename,' does not exist '])
dat.filename = filename;

if isoctave
  pkg('load','netcdf')
end

dat.simdate(1:3) = double(ncread(filename, 'ymd'));

try
  dat.simdate(4) = ncread(filename, 'UThour');
catch
  dat.simdate(4) = ncread(filename, 'UTsec') / 3600;
end

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
