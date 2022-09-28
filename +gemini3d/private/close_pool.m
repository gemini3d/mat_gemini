function close_pool()

% in case Matlab PCT was invoked for model.setup, shut it down, otherwise too much RAM can
% be wasted while PCT is idle--like several gigabytes.

if gemini3d.sys.has_parallel()
  delete(gcp('nocreate'))
end

end
