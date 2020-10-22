function zenodo_zip(path, glob, saveplot_fmt)
% zips directories matching glob under path
% we zip and plot as two steps to avoid making
% plots in frequently downloaded data
arguments
  path (1,1) string
  glob (1,1) string = "*"
  saveplot_fmt (1,:) string = "png"
end

path = gemini3d.fileio.expanduser(path);

if ~contains(glob, '*')
  % if given single directory, will list files in that directory instead of the directory
  glob = glob + "*";
end
dirs = dir(fullfile(path, glob));
assert(~isempty(dirs), 'did not find any dirs under %s', path)

for i = 1:length(dirs)
  if ~dirs(i).isdir || any(dirs(i).name == [".", ".."]), continue, end
  name = dirs(i).name;
  zip_file = fullfile(path, name + ".zip");
  zip(zip_file, fullfile(path, name))
end

for i = 1:length(dirs)
  % parfor crashes, even when restricting to one worker
  if ~dirs(i).isdir || any(dirs(i).name == [".", ".."]), continue, end
  name = dirs(i).name;
  gemini3d.plot(fullfile(path, name), saveplot_fmt)
  zip_file = fullfile(path, name + "_plots.zip");
  zip(zip_file, fullfile(path, name, "plots"))
end

end %function
