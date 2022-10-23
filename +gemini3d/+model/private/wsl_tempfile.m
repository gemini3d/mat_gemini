function path = wsl_tempfile()

[stat, path] = system("wsl mktemp -u");

assert(stat == 0, "could not get wsl mktemp " + path)

path = strip(string(path));

end
