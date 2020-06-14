function results = checkcode_recursive(folder, verbose)
%% lints each Matlab .m file in folder.
% distinct from mlintrpt() in that this function is all CLI instead of GUI
%
% Copyright (c) 2020 Michael Hirsch (MIT License)

narginchk(0,2)
if nargin < 1, folder = pwd; end
if nargin < 2, verbose = false; end
assert(is_folder(folder), '%s is not a folder', folder)

flist = dir([folder, '/**/*.m']);
N = length(flist);

fprintf('checking %d Matlab files under %s', N, folder)

h = waitbar(0);

for i = 1:N
  file = fullfile(flist(i).folder, flist(i).name);
  waitbar(i/N, h, ['checking ',flist(i).name])
  res = checkcode(file);
  if ~isempty(res)
    [~, stem] = fileparts(file);
    results.(stem) = res;
    if verbose
      fprintf('%s has %d lint messages.', file, length(res));
    end
  end
end % for

close(h);

if ~nargout, clear('results'), end

end % function
