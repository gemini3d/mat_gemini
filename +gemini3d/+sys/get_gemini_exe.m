function exe = get_gemini_exe(exe)
arguments
  exe string = string.empty
end

if isempty(exe)
  exe = fullfile(get_gemini_root(), "build/gemini.bin");
end
if ispc && ~endsWith(exe, ".exe")
  exe = exe + ".exe";
end

if ~isfile(exe)
  error('get_gemini_exe:file_not_found', "Gemini.bin executable not found in " + fileparts(exe))
end
%% sanity check gemini.bin executable
prepend = gemini3d.sys.modify_path();
[ret, msg] = system(prepend + " " + exe);
assert(ret==0, 'problem with %s: %s', exe, msg)

end % function


function gemini_root = get_gemini_root()

gemini_root = getenv('GEMINI_ROOT');
if isempty(gemini_root)
  cwd = fileparts(mfilename('fullpath'));
  gemini_root = fullfile(cwd, "../../gemini3d");
end
if ~isfolder(gemini_root)
  error('get_gemini_exe:file_not_found', 'Gemini3D directory not found: %s\n\nPlease specify top-level path to Gemini in environment variable GEMINI_ROOT', gemini_root)
end

end % function
