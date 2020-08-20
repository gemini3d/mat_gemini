function cfg = make_valid_paths(cfg, top)
%% resolve all paths in the config struct
import gemini3d.fileio.expanduser

narginchk(1,2)

if isfield(cfg, 'outdir')
  cfg.outdir = expanduser(cfg.outdir);
end

if nargin < 2
  top = cfg.outdir;
else
  top = expanduser(top);
end

cfg.input_dir = fullfile(top, 'inputs');

for n = {'indat_size', 'indat_grid', 'indat_file'}
  cfg.(n{:}) = make_valid_filename(cfg.(n{:}), top);
end

for n = {'eq_dir', 'eq_zip', 'E0_dir', 'prec_dir'}
  if isfield(cfg, n{:}) && ~isempty(cfg.(n{:}))
    cfg.(n{:}) = make_valid_folder(cfg.(n{:}), top);
  end
end


end % function


function folder = make_valid_folder(folder, top)
import gemini3d.fileio.*

folder = expanduser(folder);
% in case absolute path was specified

if ~isfolder(folder)  && ~is_absolute_path(folder)
  folder = fullfile(top, folder);
end

end % function


function filename = make_valid_filename(filename, top)

filename = gemini3d.fileio.expanduser(filename);
% in case absolute path was specified

if ~isfolder(fileparts(filename))
  filename = fullfile(top, filename);
end

end % function
