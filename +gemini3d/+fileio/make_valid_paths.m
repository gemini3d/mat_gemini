function cfg = make_valid_paths(cfg, top, file_format)
%% resolve all paths in the config struct
arguments
  cfg (1,1) struct
  top string = string.empty
  file_format string = string.empty
end

import stdlib.fileio.expanduser
import stdlib.fileio.with_suffix

if isfield(cfg, 'outdir')
  cfg.outdir = expanduser(cfg.outdir);
elseif ~isempty(top)
  cfg.outdir = expanduser(top);
else
  error('must specify output directory')
end


if isempty(top)
  top = cfg.outdir;
else
  top = expanduser(top);
end

cfg.input_dir = fullfile(top, 'inputs');

for n = ["indat_size", "indat_grid", "indat_file"]
  cfg.(n) = make_valid_filename(cfg.(n), top);
  if ~isempty(file_format)
    cfg.(n) = with_suffix(cfg.(n), "." + file_format);
  end
end

for n = ["eq_dir", "eq_archive", "E0_dir", "prec_dir"]
  if isfield(cfg, n) && ~isempty(cfg.(n))
    cfg.(n) = make_valid_folder(cfg.(n), top);
  end
end

end % function


function folder = make_valid_folder(folder, top)
import gemini3d.fileio.expand_simroot
import stdlib.fileio.expanduser
import stdlib.fileio.is_absolute_path

folder = expand_simroot(folder);

folder = expanduser(folder);
% in case absolute path was specified

if ~isfolder(folder) && ~is_absolute_path(folder)
  folder = fullfile(top, folder);
end

end % function


function filename = make_valid_filename(filename, top)
import stdlib.fileio.expanduser
import gemini3d.fileio.expand_simroot

filename = expand_simroot(filename);

filename = expanduser(filename);
% in case absolute path was specified

if ~isfolder(fileparts(filename))
  filename = fullfile(top, filename);
end

end % function
