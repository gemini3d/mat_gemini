function grid(p, xg)
%% write grid to file
% includes STUFF NOT NEEDED BY FORTRAN CODE BUT POSSIBLY USEFUL FOR PLOTTING
arguments
  p (1,1) struct
  xg (1,1) struct
end

gemini3d.sys.check_stdlib()

%% check the input struct to make sure needed fields are present
assert(isfield(p, "indat_grid"), "gemini3d:write:grid:keyError", "config field indat_grid missing...")
assert(isfield(p, "indat_size"), "gemini3d:write:grid:keyError", "config field indat_size missing...")

%% sanity check grid
assert(gemini3d.check_grid(xg), 'gemini3d:write:grid:value_error', 'problematic grid values')

%% output directory for the simulation grids may be different
% e.g. "inputs" than the base simdir
% because grid is so important, and to catch bugs in file I/O early, let's verify the file

gdir = stdlib.parent(p.indat_grid);
stdlib.makedir(gdir)

write_grid_hdf5(p, xg)

[xg_check, ok] = gemini3d.read.grid(p.indat_grid);

rtol = 1e-7;  % allow for single precision
names = ["x1", "x1i", "dx1b", "dx1h", "x2", "x2i", "dx2b", "dx2h", "x3", "x3i", "dx3b", "dx3h", ...
  "h1", "h2", "h3", "h1x1i", "h2x1i", "h3x1i", "h1x2i", "h2x2i", "h3x2i", "h1x3i", "h2x3i", "h3x3i", ...
  "gx1", "gx2", "gx3", "Bmag", "I", "nullpts", "e1", "e2", "e3", "er", "etheta", "ephi", ...
  "r", "theta", "phi", "x", "y", "z"];
for n = names
  assert(gemini3d.assert_allclose(xg.(n), xg_check.(n), 'rtol', rtol, 'warnonly', true, 'err_msg', n), ...
      "gemini3d:write:grid:allclose_error", "mismatch" + n)
end

if ~ok
  error('write:grid:value_error', 'values of grid are not suitable %s', p.indat_grid)
end

gemini3d.write.meta(fullfile(gdir, 'setup_grid.json'), gemini3d.git_revision(), p)

end % function
