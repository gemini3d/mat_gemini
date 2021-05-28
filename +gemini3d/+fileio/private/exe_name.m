function exe = exe_name(exe)
arguments
  exe string
end

if ispc
  if ~endsWith(exe, ".exe")
    exe = exe + ".exe";
  end
end

end
