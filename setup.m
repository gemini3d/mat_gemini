function setup()
%% run this before running Gemini Matlab scripts
narginchk(0,0)

cwd = fileparts(mfilename('fullpath'));
addpath(genpath(fullfile(cwd, 'matlab')), 'tests')

gemini_root = absolute_path(fullfile(cwd, '../gemini/'));
if is_folder(gemini_root)
  setenv('GEMINI_ROOT', gemini_root)
end

setenv('GEMINI_MATLAB', fullfile(cwd, 'matlab'))

end % function
