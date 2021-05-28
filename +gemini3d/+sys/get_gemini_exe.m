function exe = get_gemini_exe(exe)
arguments
  exe string = string.empty
end

runner_name = "gemini3d.run";

exe = gemini3d.find.which(exe);

if isempty(exe)
  srcdir = gemini3d.fileio.expanduser(getenv("GEMINI_ROOT"));
  if ~isfolder(srcdir)
    cwd = fileparts(mfilename('fullpath'));
    run(fullfile(cwd, "../../setup.m"))
    srcdir = gemini3d.fileio.expanduser(getenv("GEMINI_ROOT"));
  end
  bindir = fullfile(srcdir, "build");
  exe = gemini3d.find.which(runner_name, bindir);

  if isempty(exe)
    gemini3d.sys.cmake(srcdir, bindir, "gemini3d.run gemini.bin");
    exe = gemini3d.find.which(runner_name, bindir);
  end
end
assert(~isempty(exe), "failed to build/find %s", exe)
%% sanity check Gemini executable
prepend = gemini3d.sys.modify_path();
[ret, msg] = system(prepend + " " + exe);

assert(ret == 0, "problem with Gemini executable: %s  error: %s", exe, msg)

end % function
