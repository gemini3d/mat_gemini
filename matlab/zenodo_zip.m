function zenodo_zip(path, glob, saveplot_fmt)
% zips directories matching glob under path
% we zip and plot as two steps to avoid making
% plots in frequently downloaded data

if nargin < 3
  saveplot_fmt = 'png';
end

path = expanduser(path);

dirs = dir(fullfile(path, glob));
assert(~isempty(dirs), 'did not find any dirs under %s', path)

for i = 1:length(dirs)
  if ~dirs(i).isdir, continue, end
  name = dirs(i).name;
  zip(fullfile(path, [name, '.zip']), fullfile(path, name))
end

for i = 1:length(dirs)
  % parfor crashes, even when restricting to one worker
  if ~dirs(i).isdir, continue, end
  name = dirs(i).name;
  plotall(fullfile(path, name), saveplot_fmt, [], [], false)
  zip(fullfile(path, [name, '_plots.zip']), fullfile(path, name, 'plots'))
end

end %function
