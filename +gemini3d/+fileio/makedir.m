function makedir(direc)
%% malformed paths can be "created" but are not accessible.
% This function works around that bug in Matlab mkdir().

narginchk(1,1)

direc = gemini3d.fileio.expanduser(direc);

if isfolder(direc), return, end

mkdir(direc);

if ~isfolder(direc)
  error('makedir:not_a_directory', 'not a directory %s', direc)
end

end
