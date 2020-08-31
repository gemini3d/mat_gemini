function makedir(direc)
%% malformed paths can be "created" but are not accessible.
% This function works around that bug in Matlab mkdir().
arguments
  direc (1,1) string
end

direc = gemini3d.fileio.expanduser(direc);

if isfolder(direc), return, end

mkdir(direc);

if ~isfolder(direc)
  error('makedir:not_a_directory', 'not a directory %s', direc)
end

end
