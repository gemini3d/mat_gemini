function copy_file(in, out)
%% copy_file(path) overloads copyfile with tilde expansion

copyfile(absolute_path(in), absolute_path(out))
end
