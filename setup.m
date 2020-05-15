function setup()
%% run this before running Gemini Matlab scripts

cwd = fileparts(mfilename('fullpath'));
R = fullfile(cwd, 'matlab');
for p = {'', 'vis', 'vis/plotfunctions', 'setup', 'setup/gridgen'}
  addpath(fullfile(R, p{:}))
end

isci = strcmp(getenv('CI'), 'true');
gemini_root = absolute_path([cwd, '/../gemini/']);
if ~isci && ~is_folder(gemini_root)
  error('setup:file_not_found', 'could not find the Gemini Fortran code root folder')
end

setenv('GEMINI_MATLAB', fullfile(cwd, 'matlab'))
setenv('GEMINI_ROOT', gemini_root)

end % function
