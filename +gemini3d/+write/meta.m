function meta(filename, in1, cfg)
% save metadata to JSON file for provenance
arguments
  filename (1,1) string
  in1 (1,1) struct
  cfg (1,1) struct
end

filename = gemini3d.fileio.expanduser(filename);

mat = struct("arch", computer('arch'), "version", version());
git = struct("version", in1.git_version, "remote", in1.remote, "branch", in1.branch, ...
"commit", in1.commit, "porcelain", in1.porcelain);

js = struct("matlab", mat, "git", git);

if isfield(cfg, "eq_dir")
  js.eq = struct("eq_dir", cfg.eq_dir);
  md5fn = fullfile(cfg.eq_dir, "md5sum.txt");
  if isfile(md5fn)
    js.eq.md5 = strtrim(fileread(md5fn));
  end
end

json = jsonencode(js, "PrettyPrint", true);

fid = fopen(filename, 'w');
if fid < 1
  error('write:meta:os_error', 'could not create file %s', filename)
end

fprintf(fid, json);

fclose(fid);

end %function
