function cfg = make_valid_paths(cfg, top)
%% resolve all paths in the config struct
arguments
  cfg (1,1) struct
  top string = string.empty
end

if isfield(cfg, 'outdir')
  cfg.outdir = stdlib.expanduser(cfg.outdir);
elseif ~isempty(top)
  cfg.outdir = stdlib.expanduser(top);
else
  error('must specify output directory')
end


if isempty(top)
  top = cfg.outdir;
else
  top = stdlib.expanduser(top);
end

cfg.input_dir = fullfile(top, 'inputs');

for n = ["indat_size", "indat_grid", "indat_file"]
  assert(isfield(cfg, n), "gemini3d:fileio:make_valid_paths:keyError", "config field missing: %s", n)
  cfg.(n) = make_valid_filename(cfg.(n), top);
end

for n = ["eq_dir", "eq_archive", "E0_dir", "prec_dir"]
  if isfield(cfg, n) && ~isempty(cfg.(n))
    cfg.(n) = make_valid_folder(cfg.(n), top);
  end
end

end % function


function folder = make_valid_folder(folder, top)

folder = gemini3d.fileio.expand_envvar(folder);

folder = stdlib.expanduser(folder);
% in case absolute path was specified

if ~isfolder(folder) && ~stdlib.is_absolute(folder)
  folder = fullfile(top, folder);
end

end % function


function filename = make_valid_filename(filename, top)

filename = gemini3d.fileio.expand_envvar(filename);

filename = stdlib.expanduser(filename);
% in case absolute path was specified

if ~isfolder(fileparts(filename))
  filename = fullfile(top, filename);
end

end % function
