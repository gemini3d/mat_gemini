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

assert(isfolder(topdir), [topdir, ' is not a folder'])

%% run each simulation
if isempty(only)
  names = dir(fullfile(topdir));
else
  names = dir(fullfile(topdir, ['*', only, '*']));
end
names = {names.name};
for c = names
  [~, name] = fileparts(c{:});

  if size(name) < 2 % not an expected directory
    continue
  end

  run_gemini(fullfile(topdir, name), fullfile(outdir, name), gemini_exe)
end

end % function
