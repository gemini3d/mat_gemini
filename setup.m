function setup()
%% run this before running Gemini Matlab scripts

cwd = fileparts(mfilename('fullpath'));

for p = {'matlab', 'matlab/vis', 'matlab/vis/plotfunctions', 'matlab/setup', 'matlab/setup/gridgen'}
  addpath([cwd, '/', p{:}])
end

isci = strcmp(getenv('CI'), 'true');
gemini_root = absolute_path([cwd, '/../gemini/']);
if ~is_folder(gemini_root) && ~isci
  error('setup:file_not_found', 'could not find the Gemini Fortran code root folder')
end

setenv('GEMINI_MATLAB', [cwd, '/matlab'])
setenv('GEMINI_ROOT', gemini_root)

end % function
