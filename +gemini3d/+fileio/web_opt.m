function w = web_opt(ssl_verify)
arguments
  ssl_verify (1,1) logical = true
end

if ~ssl_verify
  % disable SSL -- but better to fix your SSL certificates
  w = weboptions('CertificateFilename', '', 'Timeout', 15);
elseif isfile(getenv("SSL_CERT_FILE"))
  w = weboptions('CertificateFilename', getenv("SSL_CERT_FILE"), 'Timeout', 15);
else
  w = weboptions('Timeout', 15);  % 5 seconds has nuisance timeouts
end

end
