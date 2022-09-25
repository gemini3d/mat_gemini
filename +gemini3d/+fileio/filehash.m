function hash = filehash(file, type)
% compute hash of file
arguments
  file (1,1) string {mustBeFile}
  type (1,1) string {mustBeMember(type, ["md5", "sha1", "sha256"])}
end

[stat,hash] = system("cmake -E " + type + "sum " + file);

assert(stat == 0, "gemini3d:fileio:filehash:runtime_error", "Could not compute hash: %s", hash)

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
end

end % function
