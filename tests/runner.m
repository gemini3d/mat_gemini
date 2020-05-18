function runner(name)

stem = name(1:end-3);
ext = name(end-1:end);

filename = 'config.nml';
switch ext
  case 'nc'
    filename = 'config_nc4.nml';
    if exist('nccreate', 'file') ~= 2
      fprintf(2, 'SKIP: %s\n', name);
      return
    end
  case 'h5'
    if  exist('h5create', 'file') ~= 2
      fprintf(2, 'SKIP: %s\n', name);
      return
  end
end

try
  p = model_setup(fullfile(stem, filename));

  assert(is_file(p.indat_size), [name, ' simsize missing'])

  if isfield(p, 'E0_dir')
    assert(is_file(fullfile(p.E0_dir, ['20130220_18000.000000.', ext])), [name, ' Efield file missing'])
  end

  if isfield(p, 'prec_dir')
    assert(is_file(fullfile(p.prec_dir, ['20130220_18000.000000.', ext])), [name, ' precip file missing'])
  end

catch e
  if ~strcmp(e.identifier, 'readgrid:file_not_found')
    rethrow(e)
  end
end

end
