function runner(name, file_format)

narginchk(2,2)
validateattributes(name, {'char'}, {'vector'}, mfilename, 'test name', 1)
validateattributes(file_format, {'char'}, {'vector'}, mfilename, 'test file format (nc, h5)', 2)

cwd = fileparts(mfilename('fullpath'));
% tests are intentionally setup with relative directory, so make sure we're
% in the right working dir
cd(fullfile(cwd,'..'))

ref_dir = fullfile(cwd, 'reference');
test_dir = fullfile(ref_dir, ['test', name]);
%% check if capaable of requested file format
if ~check_file_format(file_format)
  fprintf(2, 'SKIP: %s due to missing %s library\n', name, file_format);
  return
end
%% get files if needed
download_and_extract(name, ref_dir)
%% setup new test data
try
  p = read_nml(test_dir);
  p.file_format = file_format;
  p = model_setup(p);

  if isfield(p, 'E0_dir')
    assert(is_file(fullfile(p.E0_dir, ['20130220_18000.000000.', ext])), '%s Efield file missing', name)
  end

  if isfield(p, 'prec_dir')
    assert(is_file(fullfile(p.prec_dir, ['20130220_18000.000000.', ext])), '%s precip file missing', name)
  end

catch e
  switch e.identifier
    case 'get_frame_filename:file_not_found', fprintf(2, 'SKIP: %s due to no data file\n', name)
    otherwise, rethrow(e)
  end
end

end  % function


function ok = check_file_format(file_format)
% Octave doesn't currently have HDF5, but can do NetCDF4 with optional
% toolbox.
% Matlab has HDF5 and NetCDF4
%
narginchk(1,1)

if strcmp(file_format, 'nc')
  ok = logical(exist('nccreate', 'file'));
elseif strcmp(file_format, 'h5')
  ok = logical(exist('h5create', 'file') == 2);
else
  ok = false;
end

end % function
