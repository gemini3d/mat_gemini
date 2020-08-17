function makedir(direc)
%% malformed paths can be "created" but are not accessible.
% This function workaround that bug in Matlab mkdir().

narginchk(1,1)

direc = gemini3d.fileio.expanduser(direc);

if ~isfolder(direc)
  mkdir(direc);
end

if ~isfolder(direc)
  error('makedir:not_a_directory', 'not a directory %s', direc)
end

end
