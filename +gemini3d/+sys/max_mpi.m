function N = max_mpi(dsize, max_cpu)
%% maximum MPI images for this grid size (lx1,lx2,lx3)

arguments
  dsize (1,3) {mustBeInteger,mustBePositive,mustBeFinite}
  max_cpu (1,1) {mustBeInteger,mustBeFinite,mustBeNonnegative} = 0
end

if isempty(max_cpu) || max_cpu < 1
  max_cpu = gemini3d.sys.get_cpu_count();
end

if dsize(3) == 1
  % 2D east-west sim
  N = max_gcd(dsize(2), max_cpu);
elseif dsize(2) == 1
  % 2D north-south sim
  N = max_gcd(dsize(3), max_cpu);
else
  % 3D
  N = max_gcd2(dsize(2:3), max_cpu);
end % if

end % function


function N = max_gcd(s, M)
%% find the Greatest Common Factor to evenly partition the simulation grid
%
% Output range is [M, 1]

arguments
  s (1,1) {mustBePositive,mustBeInteger}
  M (1,1) {mustBePositive,mustBeInteger}
end


N = 1;
for i = M:-1:2
  N = max(gcd(s, i), N);
  if i < N, break, end
end % for i

end % function


function N = max_gcd2(s, M)
%% find the Greatest Common Factor to evenly partition the simulation grid
%
% Output range is [M, 1]
%
% 1. find factors of each dimension
% 2. choose partition that yields highest CPU count usage

arguments
  s (1,2) {mustBePositive,mustBeInteger}
  M (1,1) {mustBePositive,mustBeInteger}
end

f2 = [];
f3 = [];

for m = M:-1:1
  f2(end+1) = max_gcd(s(1), m); %#ok<AGROW>
end

for m = M:-1:1
  f3(end+1) = max_gcd(s(2), m); %#ok<AGROW>
end


N = 1;
for i = f2
  for j = f3
    if M >= i * j && i * j > N
      N = i * j;
    end
  end
end

end % function
