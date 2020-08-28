function dat = load_precip(filename, time)
arguments
  filename (1,1) string
  time (1,1) datetime = []
end

if ~isempty(time)
  assert(isfolder(filename), 'either filename or folder + time')
  filename = gemini3d.get_frame_filename(filename, time);
end
assert(isfile(filename), 'precip file not found %s', filename)

[~,~,ext] = fileparts(filename);

switch ext
  case '.h5', dat = load_h5(filename);
  case '.nc', dat = load_nc(filename);
  case '.dat', error('load_precip:value_error', 'raw .dat files are not supported by load_precip')
  otherwise, error('load_precip:value_error', 'could not determine file type %s', filename)
end

end % function


function dat = load_h5(filename)

dat.Q = h5read(filename, '/Qp');
dat.E0 = h5read(filename, '/E0p');

end % function


function dat = load_nc(filename)

dat.Q = ncread(filename, 'Qp');
dat.E0 = ncread(filename, 'E0p');

end % function
