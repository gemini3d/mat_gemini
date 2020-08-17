function exe = get_gemini_exe(params)

narginchk(0,1)

if nargin >= 1 && isfield(params, 'gemini_exe')
  exe = params.gemini_exe;
else
  exe = find_gemini();
end

if ~isfile(exe)
  error('get_gemini_exe:file_not_found', 'Gemini.bin executable not found in %s', fileparts(exe))
end
%% sanity check gemini.bin executable
prepend = gemini3d.sys.modify_path();
[ret, msg] = system([prepend, ' ', exe]);
assert(ret==0, 'problem with %s: %s', exe, msg)

end % function


function exe = find_gemini()

narginchk(0,0)

gemini_root = getenv('GEMINI_ROOT');
assert(~isempty(gemini_root), 'specify top-level path to Gemini in environment variable GEMINI_ROOT')
assert(isfolder(gemini_root), 'Gemini3D directory not found: %s', gemini_root)
exe = fullfile(gemini_root, 'build/gemini.bin');
if ispc
  exe = [exe, '.exe'];
end

end
