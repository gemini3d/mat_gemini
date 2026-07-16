classdef StdlibCheck < matlab.unittest.TestCase

methods (TestClassSetup)
function check_stdlib(tc)
try
  gemini3d.sys.check_stdlib()
catch e
  tc.fatalAssertFail(e.message)
end
end
end

end
