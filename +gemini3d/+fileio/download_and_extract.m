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

data_dir = gemini3d.fileio.expanduser(data_dir);
test_dir = fullfile(data_dir, "test" + test_name);
if isfolder(test_dir)
  return
end

zipfile = download_data(test_name, data_dir, url_ini);

%% extract
try
  unzip(zipfile, data_dir)
catch e
  if strcmp(e.identifier, 'MATLAB:io:archive:unzip:invalidZipFile')
    % botched download
    delete(zipfile)
    zipfile = download_data(test_name, data_dir, url_ini);
    unzip(zipfile, data_dir)
  end
end

end % function


function zipfile = download_data(test_name, data_dir, url_ini)

if isempty(url_ini)
  url_ini = fullfile(fileparts(mfilename('fullpath')), "../+tests/gemini3d_url.json");
end

gemini3d.fileio.makedir(data_dir)

urls = jsondecode(fileread(url_ini));

zipfile = fullfile(data_dir, "test" + test_name + ".zip");

if isfile(zipfile) && dir(zipfile).bytes > 10000
  return
end

if isfile(getenv("SSL_CERT_FILE"))
  web_opts = weboptions('CertificateFilename', getenv("SSL_CERT_FILE"), 'Timeout', 15);
else
  web_opts = weboptions('Timeout', 15);  % 5 seconds has nuisance timeouts
end

k = "url";
url = urls.("x" + test_name).(k);
websave(zipfile, url, web_opts);

check_data(test_name, zipfile, urls)

end


function check_data(test_name, zipfile, urls)

k = "md5";

if isfield(urls.("x" + test_name), k)
  exp_hash = urls.("x" + test_name).(k);
  hash = gemini3d.fileio.md5sum(zipfile);
  if hash ~= exp_hash
    warning('%s md5 hash does not match, file may be corrupted or incorrect data', zipfile)
  end
end

end
