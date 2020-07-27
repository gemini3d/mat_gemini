function zenodo_zip(path, glob)
% zips directories matching glob under path

path = expanduser(path);

dirs = dir(fullfile(path, glob));
for i = 1:length(dirs)
  name = dirs(i).name;
  zip(fullfile(path, [name, '.zip']), fullfile(path, name))
end

end %function
