function postprocess(cfg, xg)
% based on Namelist "setup_functions" comma-separated string array of function names, process data
% current limitation: function arguments must be:
%
% myfun(cfg, xg)
%
arguments
  cfg (1,1) struct
  xg (1,1) struct
end

if isfield(cfg, 'setup_functions')
  for name = cfg.setup_functions(:)'
    func = str2func(name);
    func(cfg, xg)
  end

  return
end
%% potential boundary conditions
if isfield(cfg, 'E0_dir')
  gemini3d.efield.Efield_BCs(cfg, xg);
end

%% aurora
if isfield(cfg, 'prec_dir')
  gemini3d.particles.particles_BCs(cfg, xg)
end

end % function
