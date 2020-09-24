name = "2dew_eq";

cwd = fileparts(mfilename('fullpath'));

% get files if needed
gemini3d.fileio.download_and_extract(name, fullfile(cwd, "data"))
%% dry run
gemini3d.gemini_run(...
  fullfile(tempdir, name), ...
  'config', "+gemini3d/+tests/data/test" + name, ...
  'dryrun', true)
