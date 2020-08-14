function dat = load_precip(filename, time)

narginchk(1,2)

if nargin > 1
  assert(gemini3d.fileio.is_folder(filename), 'either filename or folder + time')
  filename = gemini3d.get_frame_filename(filename, time);
end
assert(gemini3d.fileio.is_file(filename), 'precip file not found %s', filename)

[~,~,ext] = fileparts(filename);

switch ext
  case '.h5', dat = load_h5(filename);
  case '.nc', dat = load_nc(filename);
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
