cwd = fileparts(mfilename('fullpath'));
%% lint
checkcode_recursive(fullfile(cwd, '..'))
