function dat = load_Efield(filename, time)

narginchk(1,2)

if nargin > 1
  assert(isfolder(filename), 'either filename or folder + time')
  filename = gemini3d.get_frame_filename(filename, time);
end
assert(isfile(filename), 'E-field file not found %s', filename)

[~,~,ext] = fileparts(filename);

switch ext
  case '.h5', dat = load_h5(filename);
  case '.nc', dat = load_nc(filename);
  otherwise, error('load_Efield:value_error', 'could not determine file type %s', filename)
end

end % function


function dat = load_h5(filename)

for k = {'flagdirich', 'Exit', 'Eyit', 'Vminx1it', 'Vmaxx1it', 'Vminx2ist', 'Vmaxx2ist', 'Vminx3ist', 'Vmaxx3ist'}
  dat.(k{:}) = h5read(filename, ['/', k{:}]);
end

end % function


function dat = load_nc(filename)

for k = {'flagdirich', 'Exit', 'Eyit', 'Vminx1it', 'Vmaxx1it', 'Vminx2ist', 'Vmaxx2ist', 'Vminx3ist', 'Vmaxx3ist'}
  dat.(k{:}) = ncread(filename, ['/', k{:}]);
end

end % function
