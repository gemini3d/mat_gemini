function model_setup(p)
%% determines what kind of setup is needed and does it.

%% parse input
narginchk(1,1)
if isstruct(p)
  validateattributes(p, {'struct'}, {'scalar'}, mfilename, 'parameters', 1)
elseif ischar(p)
  % path to config.nml
  validateattributes(p, {'char'}, {'vector'}, mfilename, 'parameters', 1)
  p = read_nml(p);
else
  error('model_setup:value_error', 'need path to config.nml')
end

makedir(p.simdir)
copy_file(p.nml, p.simdir)

%% is this equilibrium or interpolated simulation
if isfield(p, 'eqdir')
  model_setup_interp(p)
else
  model_setup_equilibrium(p)
end

end % function
