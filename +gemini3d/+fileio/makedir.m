function makedir(direc)
%% malformed paths can be "created" but are not accessible.
% This function workaround that bug in Matlab mkdir().
import gemini3d.fileio.*

narginchk(1,1)

direc = expanduser(direc);

if ~is_folder(direc)
  mkdir(direc);
end

if ~is_folder(direc)
  error('makedir:not_a_directory', 'not a directory %s', direc)
end

end
