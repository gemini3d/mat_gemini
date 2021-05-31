function exe = get_gemini_exe(exe)
arguments
  exe string = string.empty
end

import stdlib.fileio.expanduser
import stdlib.fileio.which
import stdlib.sys.subprocess_run

runner_name = "gemini3d.run";

exe = which(exe);

if isempty(exe)
  srcdir = expanduser(getenv("GEMINI_ROOT"));
  if ~isfolder(srcdir)
    cwd = fileparts(mfilename('fullpath'));
    run(fullfile(cwd, "../../setup.m"))
    srcdir = expanduser(getenv("GEMINI_ROOT"));
  end
  bindir = fullfile(srcdir, "build");
  exe = which(runner_name, bindir);

  if isempty(exe)
    gemini3d.sys.cmake(srcdir, bindir, "gemini3d.run gemini.bin");
    exe = which(runner_name, bindir);
  end
end
assert(~isempty(exe), "failed to build/find %s", exe)
%% sanity check Gemini executable
[ret, msg] = subprocess_run(exe);

assert(ret == 0, "problem with Gemini executable: %s  error: %s", exe, msg)

end % function
