function exe = get_gemini_exe(exe)
arguments
  exe string = string.empty
end

exe = gemini3d.sys.exe_name(exe);

if isempty(exe) || ~isfile(exe)
  srcdir = getenv("GEMINI_ROOT");
  if ~isfolder(srcdir)
    cwd = fileparts(mfilename('fullpath'));
    run(fullfile(cwd, "../../setup.m"))
    srcdir = getenv("GEMINI_ROOT");
  end
  bindir = fullfile(srcdir, "build");
  gemini3d.sys.cmake(srcdir, bindir, "gemini.bin");
  exe = gemini3d.sys.exe_name(fullfile(bindir, "gemini.bin"));
end
assert(isfile(exe), 'failed to build ' + exe)
%% sanity check gemini.bin executable
prepend = gemini3d.sys.modify_path();
[ret, msg] = system(prepend + " " + exe);

if ret ~= 0
  error("get_gemini_exe:runtime_error", "problem with Gemini.bin executable: %s  error: %s", exe, msg)
end

end % function
