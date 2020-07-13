function generate_reference_data(topdir, outdir, only, gemini_exe, file_format)
% generate (run) all simulations under topdir
% good to regenerate Zenodo reference data

narginchk(2, 5)

if nargin < 3, only = ''; end
if nargin < 4, gemini_exe = []; end
if nargin < 5, file_format = []; end

topdir = expanduser(topdir);
outdir = expanduser(outdir);

assert(is_folder(topdir), '%s is not a folder', topdir)

%% run each simulation
names = get_testnames(topdir, only);
if isempty(names)
  error(['No inputs under ',topdir,' with ', only])
end

gem_params = struct('overwrite', true, 'mpiexec', [] , 'file_format', file_format);

for i = 1:length(names)
  gemini_run(fullfile(topdir, names{i}), fullfile(outdir, names{i}), gemini_exe, gem_params)
end

end % function
