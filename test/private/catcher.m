function catcher(err, tc)
arguments
  err (1,1) MException
  tc (1,1) matlab.unittest.TestCase
end

if any(contains(err.message, ["msis21.parm not found", "msis20.parm not found"]))
  tc.assumeFail("MSIS 2 not enabled")
elseif err.identifier == "gemini3d:model:msis:FileNotFoundError"
  tc.assumeFail("msis_setup program not found. Compile with https://github.com/gemini3d/gemini3d/gemini3d.git")
elseif contains(err.message, "HDF5 library version mismatched error")
  tc.assumeFail("HDF5 shared library conflict Matlab <=> system:  " + err.message)
elseif contains(err.message, "GLIBCXX")
  tc.assumeFail("conflict in libstdc++ Matlab <=> system:  " + err.message)
elseif err.identifier == "MATLAB:webservices:UnknownHost"
  tc.assumeFail("no internet connection to website")
elseif err.identifier == "MATLAB:webservices:SSLConnectionSystemFailure"
  tc.assumeFail("HTTPS certificate error. Is environment variable SSL_CERT_FILE set? " + err.message)
else
  rethrow(err)
end
end
