function cfg = setup_if_needed(opts, outdir, config_path)
  arguments
    opts
    outdir (1,1) string
    config_path (1,1) string
  end

  import stdlib.fileio.expanduser

  config_path = expanduser(config_path);
  outdir = expanduser(outdir);

  cfg = gemini3d.read.config(config_path);
  cfg.outdir = outdir;

  if ~isempty(opts.ssl_verify)
    cfg.ssl_verify = opts.ssl_verify;
  end

  if opts.overwrite
    % note, if an old, incompatible shape exists this will fail.
    % we didn't want to automatically recursively delete directories,
    % so it's best to manually ensure all the old directories are removed first.
    gemini3d.model.setup(cfg)
  else
    for k = ["indat_size", "indat_grid", "indat_file"]
      if ~isfile(fullfile(cfg.outdir, cfg.(k)))
        gemini3d.model.setup(cfg)
        break
      end
    end
  end

  end % function
