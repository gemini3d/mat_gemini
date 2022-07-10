function [xg, ok] = grid(apath)
%% READS A GRID FROM MATLAB
% OR POSSIBLY FORTRAN (THOUGH THIS IS NOT YET IMPLEMENTED AS OF 9/15/2016)
% we don't use file_format because the output / new simulation may be in
% one file format while the equilibrium sim was in another file format
arguments
  apath (1,1) string
end

[apath, suffix] = gemini3d.find.simsize(apath);

switch suffix
  case '.h5', xg = read_hdf5(apath);
  otherwise, error('gemini3d:read:grid:value_error', 'unknown file type %s', filename)
end

ok = gemini3d.check_grid(xg);
if ~ok
  warning('read:grid:value_error', "grid has unsuitable values: " + apath)
end

end % function


function xgf = read_hdf5(apath)

import stdlib.hdf5nc.h5variables

fn = fullfile(apath, 'simgrid.h5');

for v = h5variables(fn)
  xgf.(v) = h5read(fn, "/" + v);
end

% do this last to avoid overwriting
xgf.filename = fn;
xgf.lx = gemini3d.simsize(apath);

end  % function read_hdf5
