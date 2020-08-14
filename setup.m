function setup()
%% run this before running Gemini Matlab scripts

narginchk(0,0)

cwd = fileparts(mfilename('fullpath'));
addpath(cwd)

gemini_root = gemini3d.fileio.absolute_path(fullfile(cwd, '../gemini3d/'));
if gemini3d.fileio.is_folder(gemini_root)
  setenv('GEMINI_ROOT', gemini_root)
end

end % function
