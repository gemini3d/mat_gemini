function git = git_revision(cwd)
% return Git metadata
%
% strtrim() removes the \n newline
arguments
  cwd (1,1) string = fileparts(mfilename('fullpath'))
end

assert(isfolder(cwd), '%s is not a folder', cwd)

% empty init in case can't read Git info
% this avoids a lot of needless "if isfield" statements in consumers
git = struct('git_version', '', 'remote', '', 'branch', '', 'commit', '', 'porcelain', false);

[ret, msg] = system("git -C " + cwd + " --version");
if ret ~= 0
  warning('Git was not available or is too old')
  return
end
git.git_version = strtrim(msg);

ret = system("git -C " + cwd + " rev-parse");
if ret~=0
  warning('%s is not a Git repo', cwd)
  return
end

[ret, msg] = system("git -C " + cwd + " rev-parse --abbrev-ref HEAD");
if ret ~= 0
  warning('Could not determine Git branch')
  return
end
git.branch = strtrim(msg);

[ret,msg] = system("git -C " + cwd + " remote get-url origin");
if ret ~= 0
  warning('Could not determine Git remote')
  return
end
git.remote = strtrim(msg);

[ret, msg] = system("git -C " + cwd + " describe --tags");
if ret ~= 0
  [ret, msg] = system("git -C " + cwd + " rev-parse --short HEAD");
end
if ret ~= 0
  warning('Could not determine Git commit')
  return
end
git.commit = strtrim(msg);

[ret, msg] = system("git -C " + cwd + " status --porcelain");
if ret ~= 0, error('Could not determine Git status'), end
if isempty(msg)
  git.porcelain = 'true';
else
  git.porcelain = 'false';
end

end % function
