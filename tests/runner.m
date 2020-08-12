function runner(name, file_format)

narginchk(2,2)
validateattributes(name, {'char'}, {'vector'}, mfilename, 'test name', 1)
validateattributes(file_format, {'char'}, {'vector'}, mfilename, 'test file format (nc, h5)', 2)

cwd = fileparts(mfilename('fullpath'));
% tests are intentionally setup with relative directory, so make sure we're
% in the right working dir
cd(fullfile(cwd,'..'))

ref_dir = fullfile(cwd, 'data');
test_dir = fullfile(ref_dir, ['test', name]);
%% get files if needed
download_and_extract(name, ref_dir)
%% setup new test data
p = read_config(test_dir);
p.file_format = file_format;
p.outdir = fullfile(tempdir, ['test',name]);

% patch eq_dir to use reference data
if isfield(p, 'eq_dir')
  eq_dir = fullfile(fileparts(test_dir), path_tail(p.eq_dir));
  if is_folder(eq_dir)
    fprintf('Using %s for equilibrium data \n', eq_dir)
    p.eq_dir = eq_dir;
  end
end

p = model_setup(p);
%% check generated files

compare_all(p.outdir, test_dir, 'in')

end  % function
