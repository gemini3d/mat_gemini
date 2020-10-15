function dat = loadframe(filename, opts)
% loadframe(filename, cfg, vars)
% load a single time step of data
%
% example use
% dat = loadframe(filename)
% dat = loadframe(folder, "time", datetime)
% dat = loadframe(filename, "config", cfg)
% dat = loadframe(filename, "vars", vars)
%
% The "vars" argument allows loading a subset of variables.
% for example:
%
% loadframe(..., "ne")
% loadframe(..., ["ne", "Te"])

arguments
  filename (1,1) string
  opts.time datetime = datetime.empty
  opts.cfg struct = struct.empty
  opts.vars (1,:) string = string.empty
end

dat = gemini3d.vis.loadframe(filename, "time", opts.time, "cfg", opts.cfg, "vars", opts.vars);

end
