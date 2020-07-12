function hash = md5sum(file)
% compute MD5 hash of file

assert(is_file(file), '%s not found', file)

hash = [];
if isoctave
  return
else
  if verLessThan('matlab', '9.7')
    return
  end
  p = pyenv();
  if isempty(p.Version) % Python not configured
    return
  end
  h = py.hashlib.md5();
  h.update(py.pathlib.Path(file).read_bytes())
  hash = char(h.hexdigest());
end

%% sanity check
assert(length(hash)==32, 'md5 hash is 32 characters')

end % function
