function extract_zstd(archive, out_dir)

if ~isfile(archive)
   error("%s is not a file", archive)
end

[ret, ~] = system("zstd -h");
if ret ~= 0
  if ismac
    msg = "brew install zstd";
  elseif isunix
    msg = "apt install zstd";
  else
    msg = "https://github.com/facebook/zstd/releases  extract and put that directory on PATH";
  end
  error("need to have Zstd installed: \n install zstd by: \n %s", msg)
end

[p, n] = fileparts(archive);
tar_arc = fullfile(p, n + ".tar");
if isfile(tar_arc)
  delete(tar_arc)
end

ret = system("zstd -d " + archive + " -o " + tar_arc);
if ret ~= 0
  error("problem extracting %s", archive)
end

untar(tar_arc, out_dir)

end
