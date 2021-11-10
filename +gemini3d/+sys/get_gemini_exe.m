function exe = get_gemini_exe(exe)
arguments
  exe (1,1) string = "gemini3d.run"
end

import stdlib.fileio.expanduser
import stdlib.fileio.which
import stdlib.sys.subprocess_run

runner_name = "gemini3d.run";

exe = which(exe);

if isempty(exe)
  src_dir = expanduser(getenv("GEMINI_ROOT"));
  assert(isfolder(src_dir), "Please set environment variable GEMINI_ROOT to top-level Gemini3D folder.")
  for b = ["../GEMINI3D-build", ".", "build", "build/Release", "build/RelWithDebInfo", "build/Debug"]
    build_dir = fullfile(src_dir, b);
    if isfolder(build_dir)
      break
    end
  end
  exe = which(runner_name, build_dir);

  assert(~isempty(exe), 'gemini3d.run executable not found under %s. Please build with cmake from top-level mat-gemini/ dir.  See README.md.', src_dir)
end
assert(~isempty(exe), "failed to build/find %s", exe)
%% sanity check Gemini executable
[ret, msg] = subprocess_run(exe);

assert(ret == 0, "problem with Gemini executable: %s  error: %s", exe, msg)

end % function
