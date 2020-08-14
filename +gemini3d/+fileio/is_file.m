function ret = is_file(path)
import gemini3d.fileio.*

narginchk(1,1)

path = expanduser(path);

if verLessThan('matlab', '9.3')
  ret = exist(path, 'file') == 2;
else
  ret = isfile(path);
end

end % function
