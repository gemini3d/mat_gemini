function ispar = is_parallel_worker()
% detects if being executed by Parallel Computing Toolbox
% e.g. in a parfor loop
%
% Reference: https://www.mathworks.com/help/parallel-computing/getcurrenttask.html
%
% test by:
% >> is_parallel_worker
%
% ans = logical 0
%
% >> parfor i = 1:1, is_parallel_worker, end
% Starting parallel pool (parpool) using the 'local' profile ...
%
% ans = logical 1

ispar = false;

if gemini3d.sys.has_parallel()
  ispar = ~isempty(getCurrentWorker());
end

end % function
