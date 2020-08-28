function lxs = simsize(path)
arguments
  path (1,1) string
end

[path, ext] = gemini3d.get_simsize_path(path);

switch ext
  case '.h5', lxs = read_h5(path);
  case '.nc', lxs = read_nc(path);
  case '.dat', lxs = read_raw(path);
  otherwise, error('simsize:value_error', 'unknown simsize file type %s', fn)
end

lxs = lxs(:).';  % needed for concatenation

end % function


function lxs = read_h5(path)

fn = fullfile(path, "simsize.h5");

varnames = gemini3d.fileio.h5variables(fn);

if any(varnames == "lxs")
  lxs = h5read(fn, '/lxs');
elseif any(varnames == "lx")
  lxs = h5read(fn, '/lx');
elseif any(varnames == "lx1")
  lxs = [h5read(fn, '/lx1'), h5read(fn, '/lx2'), h5read(fn, '/lx3')];
else
  error('simsize:lookup_error', 'did not find lxs, lx, lx1 in %s', fn)
end

end % function


function lxs = read_nc(path)

fn = fullfile(path, "simsize.nc");

varnames = gemini3d.fileio.ncvariables(fn);

if any(varnames == "lxs")
  lxs = ncread(fn, '/lxs');
elseif any(varnames == "lx")
  lxs = ncread(fn, '/lx');
elseif any(varnames == "lx1")
  lxs = [ncread(fn, '/lx1'), ncread(fn, '/lx2'), ncread(fn, '/lx3')];
end

end % function


function lxs = read_raw(path)

fid = fopen(fullfile(path, "simsize.dat"), 'r');
lxs = fread(fid, 3, 'integer*4');
fclose(fid);

end % function
