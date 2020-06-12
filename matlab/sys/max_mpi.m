function N = max_mpi(dsize, max_cpu)
% maximum MPI images for this grid size (lx1,lx2,lx3)

validateattributes(dsize, {'numeric'}, {'positive','integer', 'numel',3}, 1)

if nargin < 2 || isempty(max_cpu)
  max_cpu = get_cpu_count();
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

validateattributes(s, {'numeric'}, {'scalar','integer','positive'})
validateattributes(M, {'numeric'}, {'scalar','integer','positive'})

N = 1;
for i = M:-1:2
  N = max(gcd(s, i), N);
  if i < N, break, end
end % for i

end % function