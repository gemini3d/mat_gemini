function download_and_extract(test_name, data_dir, url_ini)
% download reference data by test name
%
% example:
%  download_and_extract('3d_fang', '~/data')

narginchk(2,3)
validateattributes(test_name, {'char'}, {'vector'}, mfilename, 'test_name',1)
validateattributes(data_dir, {'char'}, {'vector'}, mfilename, 'data directory',2)

if nargin < 3
  cwd = fileparts(mfilename('fullpath'));
  url_ini = fullfile(cwd, '../+tests/gemini3d_url.ini');
end

data_dir = gemini3d.fileio.expanduser(data_dir);
test_dir = fullfile(data_dir, ['test', test_name]);
if isfolder(test_dir)
  return
end

gemini3d.fileio.makedir(data_dir)

urls = gemini3d.vendor.ini2struct.ini2struct(url_ini);

zipfile = fullfile(data_dir, ['test', test_name, '.zip']);

if ~isfile(zipfile)
  k = 'url';
  url = urls.(['x', test_name]).(k);
  websave(zipfile, url);
end

%% md5sum check
k = 'md5';
exp_hash = urls.(['x', test_name]).(k);
hash = gemini3d.fileio.md5sum(zipfile);
if ~isempty(hash)
  if ~strcmpi(hash, exp_hash)
    warning('%s md5 hash does not match, file may be corrupted or incorrect data', zipfile)
  end
end
%% extract
unzip(zipfile, data_dir)

end % function
