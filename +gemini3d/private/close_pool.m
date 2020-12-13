function close_pool()

% in case Matlab PCT was invoked for model.setup, shut it down, otherwise too much RAM can
% be wasted while PCT is idle--like several gigabytes.

addons = matlab.addons.installedAddons();
if any(contains(addons.Name, 'Parallel Computing Toolbox'))
  delete(gcp('nocreate'))
end

end
