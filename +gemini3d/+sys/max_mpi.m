function N = max_mpi(dsize, max_cpu)
% maximum MPI images for this grid size (lx1,lx2,lx3)

arguments
  dsize (3,1) {mustBeInteger,mustBePositive,mustBeFinite}
  max_cpu (1,1) {mustBeInteger,mustBeFinite,mustBeNonnegative} = 0
end

if isempty(max_cpu) || max_cpu == 0
  max_cpu = gemini3d.sys.get_cpu_count();
end

if dsize(3) == 1
  % 2D east-west sim
  N = max_gcd(dsize(2), max_cpu);
else
  % 3D or 2D north-south sim
  N = max_gcd(dsize(3), max_cpu);
end % if

end % function


function N = max_gcd(s, M)

N = 1;
for i = M:-1:2
  N = max(gcd(s, i), N);
  if i < N, break, end
end % for i

end % function
