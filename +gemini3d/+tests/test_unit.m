%% md5sum
hash = gemini3d.fileio.md5sum(fullfile(fileparts(mfilename('fullpath')), "gemini3d_url.ini"));
if ~isempty(hash)
  assert(hash == "945935b3d4776a4b039c0020f9604751", 'md5sum %s', hash)
end
%% expanduser
pexp = gemini3d.fileio.expanduser('~/foo');
assert(~startsWith(pexp, "~"), 'expanduser')
%% is_absolute_path
% path need not exist
assert(gemini3d.fileio.is_absolute_path('~/foo'), 'expand and resolve')
%% absolute_path
pabs = gemini3d.fileio.absolute_path('2foo');
pabs2 = gemini3d.fileio.absolute_path('4foo');
assert(~startsWith(pabs, "2"), 'absolute_path')
assert(strncmp(pabs, pabs2, 2), 'absolute_path 2 files')
%% with_suffix
assert(gemini3d.fileio.with_suffix("foo.h5", ".nc") == "foo.nc", 'with_suffix switch')
%% path_tail
assert(gemini3d.fileio.path_tail("a/b/c.h5") == "c.h5", "path_tail")
%% max mpi
assert(gemini3d.sys.max_mpi([48,1,40], 5) == 5, 'max_mpi fail 5 cpu')
assert(gemini3d.sys.max_mpi([48,40,1], 5) == 5, 'max_mpi fail 5 cpu')
assert(gemini3d.sys.max_mpi([48,1,40], 6) == 5, 'max_mpi fail 6 cpu')
assert(gemini3d.sys.max_mpi([48,40,1], 6) == 5, 'max_mpi fail 6 cpu')
assert(gemini3d.sys.max_mpi([48,1,40], 8) == 8, 'max_mpi fail 8 cpu')
assert(gemini3d.sys.max_mpi([48,40,1], 8) == 8, 'max_mpi fail 8 cpu')
assert(gemini3d.sys.max_mpi([48,1,40], 28) == 20, 'max_mpi fail 28 cpu')
assert(gemini3d.sys.max_mpi([48,1,40], 28) == 20, 'max_mpi fail 28 cpu')
assert(gemini3d.sys.max_mpi([48,1,36], 28) == 18, 'max_mpi fail 28 cpu')
