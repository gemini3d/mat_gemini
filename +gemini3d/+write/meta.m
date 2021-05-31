function meta(filename, in1, cfg)
% save metadata to JSON file for provenance
arguments
  filename (1,1) string
  in1 (1,1) struct
  cfg (1,1) struct
end

import stdlib.fileio.expanduser
import stdlib.fileio.posix

filename = expanduser(filename);

mat = struct("arch", computer('arch'), "version", version());
git = struct("version", in1.git_version, "remote", in1.remote, "branch", in1.branch, ...
"commit", in1.commit, "porcelain", in1.porcelain);

js = struct("matlab", mat, "git", git);

if isfield(cfg, "eq_dir")
  % JSON does not allow unescaped backslash
  js.eq = struct("eq_dir", posix(cfg.eq_dir));
  hashfn = fullfile(cfg.eq_dir, "sha256sum.txt");
  if isfile(hashfn)
    js.eq.sha256 = strtrim(fileread(hashfn));
  end
end

if verLessThan('matlab', '9.10')
  json = jsonencode(js);
else
  json = jsonencode(js, "PrettyPrint", true);
end

fid = fopen(filename, 'w');
if fid < 1
  error('write:meta:os_error', 'could not create file %s', filename)
end

fprintf(fid, json);

fclose(fid);

end %function
