function meta(fdat, filename, namelist)

arguments
  fdat (1,1) struct
  filename (1,1) string
  namelist (1,1) string
end

filename = gemini3d.fileio.expanduser(filename);

fid = fopen(filename, 'a');
if fid < 1
  error('write.meta:os_error', 'could not create file %s', filename)
end

fprintf(fid, '&%s\n', namelist);

% variable string values get quoted per NML standard
fprintf(fid, 'matlab_version = "%s"\n', version());

fprintf(fid, 'git_version = "%s"\n', fdat.git_version);
fprintf(fid, 'git_remote = "%s"\n', fdat.remote);
fprintf(fid, 'git_branch = "%s"\n', fdat.branch);
fprintf(fid, 'git_commit = "%s"\n', fdat.commit);
fprintf(fid, 'git_porcelain = "%s"\n', fdat.porcelain);

fprintf(fid, '%s\n', '/');
fclose(fid);

end %function
