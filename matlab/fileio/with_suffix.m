function filename = with_suffix(filename, suffix)
%% switch file extension

% suffix: file extension with "." e.g. ".dat"

[direc, name, ext] = fileparts(filename);
if ~strcmp(ext, suffix)
  filename = fullfile(direc, [name, suffix]);
end

end % funciton
