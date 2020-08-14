cwd = fileparts(mfilename('fullpath'));
%% lint
gemini3d.tests.checkcode_recursive(fullfile(cwd, '..'))
