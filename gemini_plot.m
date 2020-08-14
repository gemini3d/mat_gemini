function gemini_plot(varargin)
%% Plot all quanities for all times in the simulation
%
% Parameters
% ---------
% simulation_dir: top-level path of simulation
% save_Format: 'png' or 'eps' to save. If empty do not save.

narginchk(1,2)

gemini3d.vis.plotall(varargin{:})

end % function
