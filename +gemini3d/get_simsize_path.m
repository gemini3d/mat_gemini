function [simpath, ext] = get_simsize_path(din)
%% find the path (directory, even if given filename) where simsize.* is
% also return the suffix
% the filename MUST be simsize.{h5,nc,dat}
arguments
  din (1,1) string
end

din = gemini3d.fileio.expanduser(din);

%if isfile(din)
%  [din, ~, suffixes] = fileparts(din);
%else
%  suffixes = [".h5", ".nc", ".dat"];
%end
[din, ~, ~] = fileparts(din);
suffixes = [".h5", ".nc", ".dat"];    %search all suffixes in case the inputs files are different from output

for suffix = suffixes
  for stem = ["inputs", ""]
    simsize_fn = fullfile(din, stem, "simsize") + suffix;
    if isfile(simsize_fn)
      simpath = fullfile(din, stem);
      ext = suffix;
      return
    end
  end
end

error('get_simsize_path:file_not_found', 'could not find %s/simsize.*', din)

end % function
