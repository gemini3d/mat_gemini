function catcher(err, tc)
arguments
  err (1,1) MException
  tc (1,1) matlab.unittest.TestCase
end

if endsWith(err.message, ".parm not found")
  tc.assumeFail("MSIS 2 not enabled")
elseif contains(err.message, "HDF5 library version mismatched error")
  tc.assumeFail("HDF5 shared library conflict Matlab <=> system:  " + err.message)
elseif contains(err.message, "GLIBCXX")
  tc.assumeFail("conflict in libstdc++ version between Matlab <=> system:  " + err.message)
end

switch err.identifier
  case 'gemini3d:model:msis:FileNotFoundError'
   tc.assumeFail("msis_setup program not found. Compile with https://github.com/gemini3d/gemini3d/gemini3d.git")
  case 'MATLAB:webservices:UnknownHost'
    tc.assumeFail("no internet connection to website")
  case 'MATLAB:webservices:SSLConnectionSystemFailure'
    tc.assumeFail("HTTPS certificate error. Is environment variable SSL_CERT_FILE set? " + err.message)
  case 'MATLAB:webservices:HTTP500StatusCodeError'
    tc.assumeFail('Reference data server code 500 error. Is server down or is URL now invalid?')
  otherwise
    rethrow(err)
end

end
