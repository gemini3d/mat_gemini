function x = grid1d(dist, L, parms)
%% generate a 1D grid
% not named "xgrid" to avoid conflict with Matlab toolbox
% dist: one-way distance from origin (meters)
% L: number of points
arguments
  dist (1,1) {mustBePositive}
  L (1,1) {mustBeInteger,mustBePositive}
  parms (1,:) = []
end

xmin = -dist/2;
xmax = dist/2;

if isempty(parms)
  x = uniform_grid(xmin, xmax, L);
else   %nonuniform grid; assume we are degrading resolution near the edges - this will ignore lxp
  x = nonuniform_grid(parms, xmax);
end

end % function


function x = uniform_grid(xmin, xmax, L)
arguments
  xmin (1,1)
  xmax (1,1)
  L (1,1)
end

if L == 1  % degenerate dimension
  % add 2 ghost cells on each side
  x = linspace(xmin, xmax, L + 4);
else
  % exclude the ghost cells when setting extents
  x = linspace(xmin, xmax, L);
  dx1 = x(2) - x(1);
  dxn = x(end) - x(end-1);
  % now tack on ghost cells so they are outside user-specified region
  x = [x(1) - 2*dx1, x(1)-dx1, x, x(end)+dxn, x(end)+2*dxn];
end

end % function


function x = nonuniform_grid(parms, xmax)
arguments
  parms (1,4)
  xmax (1,1)
end

degdist = parms(1);    % distance from boundary at which we start to degrade resolution
dx0 = parms(2);        % min step size for grid
dxincr = parms(3);     % max step size increase for grid
ell = parms(4);        % transition length of degradation
x2 = xmax-degdist;

%x(1)=0;
x(1) = 1/2*dx0;    %start offset from zero so we can have an even number (better for mpi)

while x(end) < xmax
  dx = dx0 + dxincr * (1/2+1/2*tanh((x(end)-x2)/ell));
  x(end+1) = x(end)+dx; %#ok<AGROW>
end %while
x = [-fliplr(x), x];

% x=[-fliplr(x(2:end)),x];

end % function
