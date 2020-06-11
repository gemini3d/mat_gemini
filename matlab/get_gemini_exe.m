function exe = get_gemini_exe(exe)

narginchk(0,1)

if nargin == 0 || isempty(exe)
  exe = find_gemini();
end

if ~is_file(exe)
  error('get_gemini_exe:file_not_found', 'Gemini.bin executable not found in %s', fileparts(exe))
end
%% sanity check gemini.bin executable
prepend = octave_mingw_path();
[ret, msg] = system([prepend, ' ', exe]);
assert(ret==0, ['problem with ', exe, ': ', msg])

end % function


function exe = find_gemini()
narginchk(0,0)

gemini_root = getenv('GEMINI_ROOT');
assert(~isempty(gemini_root), 'specify top-level path to Gemini in environment variable GEMINI_ROOT')
assert(is_folder(gemini_root), 'Gemini3D directory not found')
exe = fullfile(gemini_root, 'build/gemini.bin');
if ispc
  exe = [exe, '.exe'];
end

end
