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

urls = ini2struct(fullfile(cwd, '../../tests/url.ini'));

zipfile = fullfile(data_dir, ['test', test_name, '.zip']);

if ~is_file(zipfile)
  % this is a workaround for Octave 4.4 that inserts a trailing underscore
  if isfield(urls.(['x', test_name]), 'url')
    k = 'url';
  else
    k = 'url_';
  end
  url = urls.(['x', test_name]).(k);
  web_save(zipfile, url)
end

%% md5sum check
% this is a workaround for Octave 4.4 that inserts a trailing underscore
if isfield(urls.(['x', test_name]), 'md5')
  k = 'md5';
else
  k = 'md5_';
end
exp_hash = urls.(['x', test_name]).(k);
hash = md5sum(zipfile);
if ~isempty(hash)
  if ~strcmpi(hash, exp_hash)
    warning('%s md5 hash does not match, file may be corrupted or incorrect data', zipfile)
  end
end
%% extract
unzip(zipfile, data_dir)

end % function
