function hash = md5sum(file)
% compute MD5 hash of file
arguments
  file (1,1) string
end

file = gemini3d.fileio.expanduser(file);

assert(isfile(file), '%s not found', file)

hash = string.empty;

if verLessThan('matlab', '9.7')
  return
end

p = pyenv();
if p.Version == ""
  return
end
h = py.hashlib.md5();
h.update(py.open(file, 'rb').read())
hash = string(h.hexdigest());

%% sanity check
assert(strlength(hash)==32, 'md5 hash is 32 characters')

end % function
