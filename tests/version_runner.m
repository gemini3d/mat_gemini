% only meant for running from command line, to avoid quote escape issues
% fprint() and exit() to be compatible with Matlab < R2019a

r = runtests;

if isempty(r)
  fprintf(2, 'no tests were discovered\n')
  exit(77)
end

if any(cell2mat({r.Failed}))
  fprintf(2, 'Failed with Matlab %s\n', version)
  exit(1)
end

if verLessThan('matlab','9.6')
  exit(0)
end
