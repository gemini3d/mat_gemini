% test basic functions

cwd = fileparts(mfilename('fullpath'));
run([cwd, '/../setup.m'])
%% setup
if exist('checkcode', 'file')
  checkcode_recursive([cwd, '/../'])
else
  fprintf(2, 'SKIP: lint check\n')
end

tic
%% config.nml load test

p = read_config([cwd, '/test2dew_fang/config.nml']);

assert(p.xdist == 200000)

%% dateinc test

[ymd, utsec] = dateinc(0.5, [2012,3,27], 1500);
assert(all(ymd == [2012, 3, 27]))
assert(utsec == 1500.5)

%% test2d_eq_hdf5
if exist('h5create', 'file')
  model_setup('test2dew_eq')
else
  fprintf(2, 'SKIP: missing HDF5\n')
end

%% test2d_eq_nc4
try
  pkg load netcdf
end
if exist('nccreate', 'file')
  model_setup('test2dew_eq/config_nc4.nml')
else
  disp('SKIP: missing NetCDF4\n')
end
%% test2d_fang_hdf5
if exist('h5create', 'file')
  try
    model_setup('test2dew_fang')
  catch e
    if ~strcmp(e.identifier, 'readgrid:file_not_found')
      rethrow(e)
    end
  end
else
  fprintf(2, 'SKIP: missing HDF5\n')
end
%% test2d_fang_nc
if exist('nccreate', 'file')
  try
    model_setup('test2dew_fang/config_nc4.nml')
  catch e
    if ~strcmp(e.identifier, 'readgrid:file_not_found')
      rethrow(e)
    end
  end
else
  disp('SKIP: missing NetCDF4\n')
end

% done
toc
disp('OK: gemini-matlab')
