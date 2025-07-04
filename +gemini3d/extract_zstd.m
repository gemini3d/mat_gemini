%% EXTRACT_ZSTD extract a Zstd archive
% out_dir need not exist yet, but its parent must

function extract_zstd(archive, out_dir)
arguments
  archive {mustBeTextScalar, mustBeFile}
  out_dir {mustBeTextScalar}
end

archive = stdlib.absolute(archive);
out_dir = stdlib.absolute(out_dir);

[s, ~] = system('cmake --version');
if s ~= 0
  extract_zstd_bin(archive, out_dir)
end

[ret, msg] = stdlib.subprocess_run(["cmake", "-E", "tar", "xf", archive], cwd=out_dir);
assert(ret == 0, "problem extracting %s   %s", archive, msg)

end


function extract_zstd_bin(archive, out_dir)
% Extract .zst in two steps .zst => .tar =>
% to avoid problems with old system tar.
arguments
  archive {mustBeTextScalar}
  out_dir {mustBeTextScalar}
end

[s, ~] = system('zstd -h');
assert(s == 0, "zstd not found, please install it or add it to your PATH");

cmd = ["zstd", "-d", archive, "-o", tempname];

ret = system(cmd);
assert(ret == 0, "problem extracting %s", archive)

untar(tar_arc, out_dir)
delete(tar_arc)
end

%!testif 0
