function [path, ext] = get_simsize_path(path)
%% find the path (directory, even if given filename) where simsize.* is
% also return the suffix
% the filename MUST be simsize.{h5,nc,dat}

narginchk(1,1)

path = gemini3d.fileio.expanduser(path);

if isfile(path)
  [path, stem, ext] = fileparts(path);
  if strcmp(stem, 'simsize') && ~isempty(ext)
    return
  elseif isfile([fullfile(path,'inputs/simsize'), ext])
    path = fullfile(path, 'inputs');
    return
  elseif isfile([fullfile(path,'simsize'), ext])
    path = fullfile(path);
    return
  else
    error('get_simsize_path:file_not_found', 'could not find %s/simsize%s', path, ext)
  end
elseif isfolder(path)
  %pass
else
  error('get_simsize_path:file_not_found', '%s is not a folder or file', path)
end
%% directory given
suffixes = {'.h5', '.nc', '.dat'};

for suffix = suffixes
  for stem = {'inputs', ''}
    simsize_fn = [fullfile(path, stem{:}, 'simsize'), suffix{:}];
    if isfile(simsize_fn)
      path = fullfile(path, stem{:});
      ext = suffix{:};
      return
    end
  end
end

error('get_simsize_path:file_not_found', 'could not find %s/simsize.*', path)

end % function
