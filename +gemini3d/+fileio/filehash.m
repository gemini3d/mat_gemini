function hash = filehash(file, type)
% compute hash of file
arguments
  file (1,1) string
  type (1,1) string {mustBeMember(type, ["md5", "sha1", "sha256"])}
end

import stdlib.fileio.expanduser

file = expanduser(file);

assert(isfile(file), "%s not found", file)

[stat,hash] = system("cmake -E " + type + "sum " + file);

assert(stat == 0, "Could not compute hash: %s", hash)

switch type
case "md5"
  hash = extractBefore(hash, 33);
  assert(strlength(hash)==32, 'md5 hash is 32 characters')
case "sha1"
  hash = extractBefore(hash, 41);
  assert(strlength(hash)==40, 'sha1 hash is 32 characters')
case "sha256"
  hash = extractBefore(hash, 65);
  assert(strlength(hash)==64, 'sha256 hash is 64 characters')
otherwise
  error("unknown hash type: " + type)
end

end % function
