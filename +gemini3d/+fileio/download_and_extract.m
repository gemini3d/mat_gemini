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

gemini3d.sys.check_stdlib()

data_dir = stdlib.expanduser(data_dir);
test_dir = fullfile(data_dir, name);

archive = download_data(name, data_dir, url_ini);

gemini3d.fileio.extract_data(archive, test_dir)

end % function


function archive = download_data(name, data_dir, url_file)

if isempty(url_file)
  lib_file = fullfile(gemini3d.root(), "../cmake/libraries.json");
  url_file = fullfile(gemini3d.root(), "../test/ref_data.json");

  libs = jsondecode(fileread(lib_file));

  if ~isfile(url_file)
    websave(url_file, libs.ref_data.url, gemini3d.fileio.web_opt());
  end
end

stdlib.makedir(data_dir)

urls = jsondecode(fileread(stdlib.expanduser(url_file)));

archive = fullfile(data_dir, urls.tests.(name).archive);

if isfile(archive) && dir(archive).bytes > 10000
  check_data(name, archive, urls.tests)
  return
end

websave(archive, urls.tests.(name).url, gemini3d.fileio.web_opt());

check_data(name, archive, urls.tests)

end


function check_data(name, archive, urls)
arguments
  name (1,1) string
  archive (1,1) string
  urls (1,1) struct
end

if isfield(urls.(name), "sha256")
  disp("checking sha256sum of " + archive)
  if stdlib.sha256sum(archive) ~= urls.(name).sha256
    warning('gemini3d:fileio:download_and_extract:hash_error', ...
      '%s sha256 hash does not match, file may be corrupted', archive)
  end
end

end
