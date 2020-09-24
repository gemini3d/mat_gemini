cwd = fileparts(mfilename('fullpath'));
%% lint
gemini3d.tests.checkcode_recursive(gemini3d.fileio.absolute_path(fullfile(cwd, '..')))
