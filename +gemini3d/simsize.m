function lxs = simsize(apath)
arguments
  apath (1,1) string {mustBeNonzeroLengthText}
end

gemini3d.sys.check_stdlib()

fn = gemini3d.find.simsize(apath);
assert(~isempty(fn), "Invalid simulation directory: no simulation grid simgrid.h5 found in " + apath)

lxs = read_h5(fn);
lxs = lxs(:).';  % needed for concatenation

end % function


function lxs = read_h5(fn)

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
