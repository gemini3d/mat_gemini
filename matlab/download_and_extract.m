function download_and_extract(test_name, data_dir)
% download reference data by test name
narginchk(2,2)
validateattributes(test_name, {'char'}, {'vector'}, mfilename, 'test_name',1)
validateattributes(data_dir, {'char'}, {'vector'}, mfilename, 'data directory',2)

test_dir = fullfile(data_dir, ['test', test_name]);
if is_folder(test_dir)
  return
end

makedir(data_dir)

cwd = fileparts(mfilename('fullpath'));

urls = ini2struct(fullfile(cwd, '../tests/url.ini'));

zipfile = fullfile(data_dir, ['test', test_name, '.zip']);

if ~is_file(zipfile)
  web_save(zipfile, urls.(['x', test_name]).url)
end

unzip(zipfile, data_dir)

end % function