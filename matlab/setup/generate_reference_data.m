function generate_reference_data(topdir, outdir, only, gemini_exe)
% generate (run) all simulations under topdir
% good to regenerate Zenodo reference data

narginchk(2,4)

if nargin < 3, only = ''; end
if nargin < 4, gemini_exe = []; end

assert(is_folder(topdir), [topdir, ' is not a folder'])

%% run each simulation
names = get_testnames(topdir, only);

gem_params = struct('overwrite', true, 'mpiexec', []);

for i = 1:length(names)
  run_gemini(fullfile(topdir, names{i}), fullfile(outdir, names{i}), gemini_exe, gem_params)
end

end % function
