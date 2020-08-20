function hash = md5sum(file)
% compute MD5 hash of file

narginchk(1,1)

file = gemini3d.fileio.expanduser(file);

assert(isfile(file), '%s not found', file)

hash = '';

if verLessThan('matlab', '9.7')
  return
end
p = pyenv();
if length(p.Version) <= 1
% Python not configured. Not isempty()!
  return
end
h = py.hashlib.md5();
h.update(py.open(file, 'rb').read())
hash = char(h.hexdigest());

%% sanity check
assert(length(hash)==32, 'md5 hash is 32 characters')

end % function
