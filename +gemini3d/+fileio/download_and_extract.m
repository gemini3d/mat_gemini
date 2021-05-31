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

import stdlib.fileio.expanduser
import stdlib.fileio.extract_zstd

data_dir = expanduser(data_dir);
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
  case {".zst", ".zstd"}, extract_zstd(archive, test_dir)
  otherwise, error("gemini3d:fileio:download_and_extract", "unknown reference archive type: " + arc_type)
end

end % function


function archive = download_data(name, data_dir, url_file)

import stdlib.fileio.makedir

if isempty(url_file)
  url_file = fullfile(fileparts(mfilename('fullpath')), "../+tests/ref_data.json");
end

makedir(data_dir)

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
% assert(system(cmd) == 0, "download failed: " + urls.tests.("x" + name).url)

check_data(name, archive, urls.tests)

end


function check_data(name, archive, urls)
arguments
  name (1,1) string
  archive (1,1) string
  urls (1,1) struct
end

import stdlib.fileio.sha256sum

name = matlab.lang.makeValidName(name);

if isfield(urls.(name), "sha256")
  if sha256sum(archive) ~= urls.(name).sha256
    warning('%s sha256 hash does not match, file may be corrupted', archive)
  end
end

end
