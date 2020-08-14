function ret = is_folder(path)
import gemini3d.fileio.*

narginchk(1,1)

path = expanduser(path);

if verLessThan('matlab', '9.3')
  ret = exist(path, 'dir') == 7;
else
  ret = isfolder(path);
end

end % function
