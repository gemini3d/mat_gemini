function catcher(err, tc)
if contains(err.message, "msis20.parm not found")
  tc.assumeFail("MSIS 2 not enabled")
elseif err.identifier == "gemini3d:model:msis:FileNotFoundError"
    tc.assumeFail("msis_setup not found. Compile with gemini3d/external.git")
elseif contains(err.message, "HDF5 library version mismatched error")
  tc.assumeFail("HDF5 shared library conflict Matlab <=> system")
elseif contains(err.message, "GLIBCXX")
  tc.assumeFail("conflict in libstdc++ Matlab <=> system")
else
  rethrow(err)
end
end
