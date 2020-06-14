function hash = md5sum(file)
% compute MD5 hash of file using Powershell Get-FileHash
% returns empty [] if PowerShell not available
% md5 is fixed length 32 characters

hash = [];

assert(is_file(file), '%s not found', file)

if ispc
  [ret, msg] = system(['powershell Get-FileHash ', file, ' -Algorithm MD5']);
   pat = '(?<=MD5)\s+(\w{32})';
elseif ismac
  [ret, msg] = system(['md5 ', file]);
   pat = '\w+\s?=\s?(\w{32})$';
elseif isunix
  [ret, msg] = system(['md5sum ', file]);
   pat = '^(\w{32})(?=\s\w+)';
end
if ret ~= 0, return, end

hash = regexp(msg, pat, 'tokens');
if isempty(hash), return, end

hash = hash{1}{1};

%% sanity check
if ~isempty(hash)
  assert(ischar(hash), 'expected character output')
  assert(length(hash)==32, 'md5 hash is 32 characters')
end

hash = lower(hash);

end % function
