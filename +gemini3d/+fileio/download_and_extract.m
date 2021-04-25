function download_and_extract(name, data_dir, url_ini)
% download reference data by test name
%
% example:
%  download_and_extract('3d_fang', '~/data')
arguments
  name (1,1) string
  data_dir (1,1) string
  url_ini string = string.empty
end

data_dir = gemini3d.fileio.expanduser(data_dir);
test_dir = fullfile(data_dir, name);
if isfolder(test_dir)
  return
end

archive = download_data(name, data_dir, url_ini);

%% extract
[~,~,arc_type] = fileparts(archive);

switch arc_type
  case ".zip", unzip(archive, data_dir)
  % old zip files had vestigial folder of same name instead of just files
  case ".tar", untar(archive, test_dir)
  case {".zst", ".zstd"}, gemini3d.fileio.extract_zstd(archive, test_dir)
  otherwise, error("gemini3d:fileio:download_and_extract", "unknown reference archive type: " + arc_type)
end

end % function


function archive = download_data(name, data_dir, url_file)

if isempty(url_file)
  url_file = fullfile(fileparts(mfilename('fullpath')), "../+tests/ref_data.json");
end

gemini3d.fileio.makedir(data_dir)

urls = jsondecode(fileread(url_file));

archive = fullfile(data_dir, urls.tests.("x" + name).archive);

if isfile(archive) && dir(archive).bytes > 10000
  check_data(name, archive, urls.tests)
  return
end

if isfile(getenv("SSL_CERT_FILE"))
  web_opts = weboptions('CertificateFilename', getenv("SSL_CERT_FILE"), 'Timeout', 15);
else
  web_opts = weboptions('Timeout', 15);  % 5 seconds has nuisance timeouts
end

websave(archive, urls.tests.("x" + name).url, web_opts);

% cmd = "curl -L -o " + archive + " '" + urls.tests.("x" + name).url + "'";
% stat = system(cmd);
% if stat ~= 0
%   error("download failed: " + urls.tests.("x" + name).url)
% end

check_data(name, archive, urls.tests)

end


function check_data(name, zipfile, urls)

k = "md5";

if isfield(urls.("x" + name), k)
  exp_hash = urls.("x" + name).(k);
  hash = gemini3d.fileio.md5sum(zipfile);
  if hash ~= exp_hash
    warning('%s md5 hash does not match, file may be corrupted or incorrect data', zipfile)
  end
end

end
