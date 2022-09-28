function ok = has_parallel()

addons = matlab.addons.installedAddons();
ok = any(addons.Name == "Parallel Computing Toolbox");

end
