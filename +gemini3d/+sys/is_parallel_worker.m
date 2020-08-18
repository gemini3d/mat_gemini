function ispar = is_parallel_worker()
% detects if being executed by Parallel Computing Toolbox
% e.g. in a parfor loop
%
% Reference: https://www.mathworks.com/help/parallel-computing/getcurrenttask.html
%

ispar = false;

addons = matlab.addons.installedAddons();
if any(contains(addons.Name, 'Parallel Computing Toolbox'))
  ispar = ~isempty(getCurrentWorker());
end

end % function
