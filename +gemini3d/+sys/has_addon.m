function ok = has_addon(name)
% Check if a specific MATLAB addon is installed and enabled.

addons = matlab.addons.installedAddons();

ok = ismember(name, addons.Name) && matlab.addons.isAddonEnabled(name);

end
