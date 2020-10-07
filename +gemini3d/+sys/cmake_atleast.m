function r = cmake_atleast(min_version)
arguments
  min_version (1,1) string
end

[ret, msg] = system("cmake --version");
if ret ~= 0
  error("cmake_atleast:runtime_error", "problem getting CMake version " + msg)
end

match = regexp(msg, "(?<=cmake version )(\d+\.\d+\.\d+)", 'match');

r = gemini3d.version_atleast(match{1}, min_version);


end
