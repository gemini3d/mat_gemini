function exe = exe_name(exe)
arguments
  exe string
end

if ispc
  if ~endsWith(exe, ".exe")
    exe = exe + ".exe";
  end
end

% use expanduser here to avoid bugs across platforms
exe = gemini3d.fileio.expanduser(exe);

end
