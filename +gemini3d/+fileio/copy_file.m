function copy_file(in, out)
%% copy_file(path) overloads copyfile with tilde expansion
% distinction: copy_file "out" must be directory.



narginchk(2,2)

in = gemini3d.fileio.expanduser(in);
out = gemini3d.fileio.expanduser(out);

if ~isfolder(out)
  error('copyfile:file_not_found', '%s is not a directory', out)
end

try
  copyfile(in, out);
catch e
  if ~strcmp(e.identifier, 'MATLAB:COPYFILE:SourceAndDestinationSame')
    rethrow(e)
  end
end

end % function
