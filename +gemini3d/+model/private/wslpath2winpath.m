function path = wslpath2winpath(p)
arguments
  p (1,1) string {mustBeNonzeroLengthText}
end

[stat, path] = system("wsl wslpath -w " + p);
assert(stat == 0, "could not convert wslpath " + path)

path = strip(string(path));

end
