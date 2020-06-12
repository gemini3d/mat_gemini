cwd = fileparts(mfilename('fullpath'));
run(fullfile(cwd, '../setup.m'))
%% is_file
assert(is_file(fullfile(cwd, '../setup.m')), 'is_file true')
assert(~is_file('~'), 'is_file false')
%% is_folder
assert(is_folder(fullfile(cwd, '..')), 'is_folder true')
assert(is_folder('~'), 'is_folder expandued')
%% expanduser
pexp = expanduser('~/foo');
assert(~strcmp(pexp(1), '~'), 'expanduser')
%% is_absolute_path
% path need not exist
assert(is_absolute_path('~/foo'), 'expand and resolve')
%% absolute_path
pabs = absolute_path('2foo');
pabs2 = absolute_path('4foo');
assert(~strcmp(pabs(1), '2'), 'absolute_path')
assert(strcmp(pabs(1:2), pabs2(1:2)), 'absolute_path 2 files')
%% dateinc
[ymd, utsec] = dateinc(0.5, [2012,3,27], 1500);
assert(all(ymd == [2012, 3, 27]))
assert(utsec == 1500.5)
%% max mpi
assert(max_mpi([48,1,40], 5) == 5, 'max_mpi fail 5 cpu')
assert(max_mpi([48,40,1], 5) == 5, 'max_mpi fail 5 cpu')
assert(max_mpi([48,1,40], 6) == 5, 'max_mpi fail 6 cpu')
assert(max_mpi([48,40,1], 6) == 5, 'max_mpi fail 6 cpu')
assert(max_mpi([48,1,40], 8) == 8, 'max_mpi fail 8 cpu')
assert(max_mpi([48,40,1], 8) == 8, 'max_mpi fail 8 cpu')
assert(max_mpi([48,1,40], 28) == 20, 'max_mpi fail 28 cpu')
assert(max_mpi([48,1,40], 28) == 20, 'max_mpi fail 28 cpu')
assert(max_mpi([48,1,36], 28) == 18, 'max_mpi fail 28 cpu')
