function download_and_extract(test_name, data_dir, url_ini)
% download reference data by test name
%
% example:
%  download_and_extract('3d_fang', '~/data')
arguments
  test_name (1,1) string
  data_dir (1,1) string
  url_ini string = string.empty
end

if isempty(url_ini)
  url_ini = fullfile(fileparts(mfilename('fullpath')), "../+tests/gemini3d_url.ini");
end

data_dir = gemini3d.fileio.expanduser(data_dir);
test_dir = fullfile(data_dir, "test" + test_name);
if isfolder(test_dir)
  return
end

gemini3d.fileio.makedir(data_dir)

urls = gemini3d.vendor.ini2struct.ini2struct(url_ini);

zipfile = fullfile(data_dir, "test" + test_name + ".zip");

if ~isfile(zipfile)
  k = "url";
  url = urls.("x" + test_name).(k);
  websave(zipfile, url);
end

%% md5sum check
k = "md5";
if any(fieldnames(urls.("x" + test_name)) == k)
  exp_hash = urls.("x" + test_name).(k);
  hash = gemini3d.fileio.md5sum(zipfile);
  if hash ~= exp_hash
    warning('%s md5 hash does not match, file may be corrupted or incorrect data', zipfile)
  end
end
%% extract
unzip(zipfile, data_dir)

end % function
