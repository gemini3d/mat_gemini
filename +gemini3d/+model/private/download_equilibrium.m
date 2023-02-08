function download_equilibrium(url, archive, ssl_verify)
arguments
  url (1,1) string {mustBeNonzeroLengthText}
  archive (1,1) string {mustBeNonzeroLengthText}
  ssl_verify (1,1) logical
end

stdlib.makedir(fileparts(archive))

websave(archive, url, gemini3d.web_opt(ssl_verify));

end
