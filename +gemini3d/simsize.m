function lxs = simsize(apath)
arguments
  apath (1,1) string
end

gemini3d.sys.check_stdlib()

[apath, ext] = gemini3d.find.simsize(apath);

switch ext
  case '.h5', lxs = read_h5(apath);
  otherwise, error('gemini3d:simsize:value_error', 'unknown file format %s', file_format)
end

lxs = lxs(:).';  % needed for concatenation

end % function


function lxs = read_h5(path)

fn = fullfile(path, "simsize.h5");

varnames = stdlib.hdf5nc.h5variables(fn);

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
