function log_meta_nml(direc, meta)

narginchk(2,2)
validateattributes(meta, {'struct'}, {'scalar'},2)

if is_folder(direc)
  metafn = fullfile(direc, 'setup_meta.nml');
elseif is_file(direc)
  direc = fileparts(direc);
  metafn = fullfile(direc, 'setup_meta.nml');
else
  error('please provide a directory or filename to log metadata to')
end

fid = fopen(metafn, 'w');
fprintf(fid, '%s\n', '&setup_meta');
fprintf(fid, 'matlab_version = %s\n', version());
fprintf(fid, 'git_version = %s\n', meta.git_version);
fprintf(fid, 'git_commit = %s\n', meta.commit);
fprintf(fid, 'git_porcelain = %s\n', meta.porcelain);
fprintf(fid, 'git_branch = %s\n', meta.branch);
fprintf(fid, '%s\n', '/');
fclose(fid);

end %function