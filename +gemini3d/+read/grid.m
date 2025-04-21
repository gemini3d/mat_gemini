function [xg, ok] = grid(apath)
%% reads simulation grid
arguments
  apath (1,1) string
end

simsize_fn = gemini3d.find.simsize(apath);
assert(~isempty(simsize_fn), "Invalid simulation directory: no simulation grid simgrid.h5 found in " + apath)

d = fileparts(simsize_fn);
simgrid_fn = fullfile(d, "simgrid.h5");

xg = read_hdf5(simgrid_fn);

ok = gemini3d.check_grid(xg);
if ~ok
  warning('read:grid:value_error', "grid has unsuitable values: " + simgrid_fn)
end

end % function


function xgf = read_hdf5(fn)

for v = stdlib.h5variables(fn)
  xgf.(v) = h5read(fn, "/" + v);
end

% do this last to avoid overwriting
xgf.filename = fn;
xgf.lx = gemini3d.simsize(fn);

end  % function read_hdf5
