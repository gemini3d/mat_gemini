function setup_post_process(cfg, xg)
% based on Namelist post_process characater array of function names, process data
narginchk(2,2)

if isfield(cfg, 'setup_functions')
  for i = 1:length(cfg.setup_functions)
    func = str2func(cfg.setup_functions{i});
    func(cfg, xg)
  end
else
%% potential boundary conditions
  if isfield(cfg, 'E0_dir')
    Efield_BCs(cfg, xg);
  end

%% aurora
  if isfield(cfg, 'prec_dir')
    particles_BCs(cfg, xg)
  end
end
