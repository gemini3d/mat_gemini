function log_meta_nml(meta, filename, namelist)

arguments
  meta (1,1) struct
  filename (1,1) string
  namelist (1,1) string
end

filename = gemini3d.fileio.expanduser(filename);

fid = fopen(filename, 'a');
if fid < 1
  error('log_meta_nml:os_error', 'could not create file %s', filename)
end

fprintf(fid, '&%s\n', namelist);

% variable string values get quoted per NML standard
fprintf(fid, 'matlab_version = "%s"\n', version());

fprintf(fid, 'git_version = "%s"\n', meta.git_version);
fprintf(fid, 'git_remote = "%s"\n', meta.remote);
fprintf(fid, 'git_branch = "%s"\n', meta.branch);
fprintf(fid, 'git_commit = "%s"\n', meta.commit);
fprintf(fid, 'git_porcelain = "%s"\n', meta.porcelain);

fprintf(fid, '%s\n', '/');
fclose(fid);

end %function
