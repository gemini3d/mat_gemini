function git = git_revision(cwd)
% return Git metadata
arguments
  cwd (1,1) string = fileparts(mfilename('fullpath'))
end

git = struct(remote='', branch='', commit='', porcelain=false);

if isMATLABReleaseOlderThan('R2023b')
  return
end

repo = gitrepo(cwd);
git.remote = repo.Remotes(1).URL;
git.branch = repo.CurrentBranch(1).Name;
git.commit = repo.LastCommit(1).ID;
git.porcelain = isempty(status(repo)) && ~repo.IsDetached;

end
