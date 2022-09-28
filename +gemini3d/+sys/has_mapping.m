function ok = has_mapping()

addons = matlab.addons.installedAddons();
ok = any(addons.Name == "Mapping Toolbox");

end
