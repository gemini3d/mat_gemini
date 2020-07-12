function cfg = make_valid_paths(cfg, top)
%% resolve all paths in the config struct
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

for n = {'eqdir', 'E0_dir', 'prec_dir'}
  if isfield(cfg, n{:}) && ~isempty(cfg.(n{:}))
    cfg.(n{:}) = make_valid_folder(cfg.(n{:}), top);
  end
end


end % function


function folder = make_valid_folder(folder, top)

folder = expanduser(folder);
% in case absolute path was specified

if ~is_folder(folder)
  folder = fullfile(top, folder);
end

end % function


function filename = make_valid_filename(filename, top)

filename = expanduser(filename);
% in case absolute path was specified

if ~is_folder(fileparts(filename))
  filename = fullfile(top, filename);
end

end % function
