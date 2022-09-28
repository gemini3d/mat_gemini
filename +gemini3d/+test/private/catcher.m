function catcher(err, tc)
if any(contains(err.message, ["msis21.parm not found", "msis20.parm not found"]))
  tc.assumeFail("MSIS 2 not enabled")
elseif err.identifier == "gemini3d:model:msis:FileNotFoundError"
    tc.assumeFail("msis_setup program not found. Compile with https://github.com/gemini3d/gemini3d/external.git")
elseif contains(err.message, "HDF5 library version mismatched error")
  tc.assumeFail("HDF5 shared library conflict Matlab <=> system")
elseif contains(err.message, "GLIBCXX")
  tc.assumeFail("conflict in libstdc++ Matlab <=> system")
elseif err.identifier == "MATLAB:webservices:UnknownHost"
  tc.assumeFail("no internet connection to website")
else
  rethrow(err)
end
end
