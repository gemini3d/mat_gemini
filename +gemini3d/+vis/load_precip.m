function dat = load_precip(filename)

[~,~,ext] = fileparts(filename);

assert(isfile(filename), ['precip file not found ', filename])

switch ext
  case '.h5', dat = load_h5(filename);
  case '.nc', dat = load_nc(filename);
  case '.dat', dat = load_raw(filename);
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


function dat = load_raw(filename)

dat = struct();
error('load_precip:load_raw:not_implemented', 'not yet implemented: raw precip read')

end % function
