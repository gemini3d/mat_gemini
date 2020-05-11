function copy_file(in, out)
%% copy_file(path) overloads copyfile with tilde expansion
narginchk(2,2)

fin = absolute_path(in);
fout = absolute_path(out);
if strcmp(fileparts(fin), fout)
  fprintf(2, 'skipping copy of file onto itself: %s\n', fin);
  return
end
copyfile(absolute_path(in), absolute_path(out));
end
