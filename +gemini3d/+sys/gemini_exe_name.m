function exe = gemini_exe_name(exe)
arguments
  exe (1,1) string = fullfile(getenv("GEMINI_ROOT"), "build/gemini.bin")
end

if ispc && ~endsWith(exe, ".exe")
  exe = exe + ".exe";
end

end
