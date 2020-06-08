function dat = load_Efield(filename)

narginchk(1,1)

assert(isfile(filename), ['E-field file not found ', filename])

[~,~,ext] = fileparts(filename);

switch ext
  case {'.h5'}, dat = load_h5(filename);
  case {'.nc'}, dat = load_nc(filename);
  case {'.dat'}, dat = load_raw(filename);
  otherwise, error('load_Efield:value_error', 'could not determine file type %', filename)
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


function dat = load_raw(filename)

dat = struct();
error('load_Efield:load_raw:not_implemented', 'not yet implemented: raw Efield read')

end % function