function generate_reference_data(topdir, outdir, only, gemini_exe)
% generate (run) all simulations under topdir
% good to regenerate Zenodo reference data

narginchk(2,4)

if nargin < 3
  only = '';
end
if nargin < 4
  gemini_exe = [];
end

assert(is_folder(topdir), [topdir, ' is not a folder'])

%% run each simulation
if isempty(only)
  found = dir(topdir);
else
  found = dir(fullfile(topdir, ['*', only, '*']));
end

names = {};
j = 0;
for i = 1:size(found)
  if found(i).isdir && length(found(i).name) > 2
    j = j+1;
    [~, name] = fileparts(found(i).name);
    names{j} = name; %#ok<AGROW>
  end
end

gem_params = struct('overwrite', true, 'mpiexec', []);

for i = 1:length(names)
  run_gemini(fullfile(topdir, names{i}), fullfile(outdir, names{i}), gemini_exe, gem_params)
end

end % function
