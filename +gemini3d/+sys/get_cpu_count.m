function N = get_cpu_count()
%% get apparent number of CPU cores

if gemini3d.isoctave
  N = idivide(nproc, 2);  % assume hyperthreading
else
  N = maxNumCompThreads;
  if N < 2  % happens on some HPC
    N = feature('NumCores');
  end
  if N < 2 && usejava('jvm')
    % assume hyperthreading
    N = java.lang.Runtime.getRuntime().availableProcessors / 2;
  end
end

N = max(N, 1);

end % function
