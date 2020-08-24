%% md5sum
hash = gemini3d.fileio.md5sum(fullfile(fileparts(mfilename('fullpath')), 'gemini3d_url.ini'));
if ~isempty(hash)
  assert(strcmp(hash, 'b5f96c19e312374a5f9839410d681514'), 'md5sum %s', hash)
end
%% expanduser
pexp = gemini3d.fileio.expanduser('~/foo');
assert(~strcmp(pexp(1), '~'), 'expanduser')
%% is_absolute_path
% path need not exist
assert(gemini3d.fileio.is_absolute_path('~/foo'), 'expand and resolve')
%% absolute_path
pabs = gemini3d.fileio.absolute_path('2foo');
pabs2 = gemini3d.fileio.absolute_path('4foo');
assert(~strcmp(pabs(1), '2'), 'absolute_path')
assert(strcmp(pabs(1:2), pabs2(1:2)), 'absolute_path 2 files')
%% with_suffix
assert(strcmp(gemini3d.fileio.with_suffix('foo.h5', '.nc'), 'foo.nc'), 'with_suffix switch')
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
