function y = ygrid_gen(ydist, lyp, yparms)
%% generate a 1D grid
% ydist: one-way y-distance from origin (meters)
% lyp: number of y-points

arguments
  ydist (1,1) {mustBePositive}
  lyp (1,1) {mustBeInteger,mustBePositive}
  yparms (1,:) double = []
end

ymin = -ydist/2;
ymax = ydist/2;

if isempty(yparms)
    y=uniform_gridy(ymin,ymax,lyp);
else
    y=nonunifrom_gridy(yparms,ymax)
end

end % function

function y=uniform_gridy(ymin,ymax,lyp)

if lyp == 1  % degenerate dimension
  % add 2 ghost cells on each side
  y = linspace(ymin, ymax, lyp + 4);
else
  % exclude the ghost cells when setting extents
  y = linspace(ymin, ymax, lyp);
  dy1 = y(2) - y(1);
  dyn = y(end) - y(end-1);
  % now tack on ghost cells so they are outside user-specified region
  y=[y(1)-2*dy1, y(1)-dy1, y, y(end)+dyn, y(end)+2*dyn];
end

end %function


function y = nonuniform_gridy(yparms, ymax)

if length(xparms) ~= 4
  error('xgrid_gen:value_error', 'xparms must have 4 parameters')
end

degdist=yparms(1);    % distance from boundary at which we start to degrade resolution
dy0=yparms(2);        % min step size for grid
dyincr=yparms(3);     % max step size increase for grid
ell=yparms(4);        % transition length of degradation
y2=ymax-degdist;

%x(1)=0;
y(1)=1/2*dy0;    %start offset from zero so we can have an even number (better for mpi)

iy=1;
while (y(iy)<ymax)
  dy = dy0 + dyincr * (1/2+1/2*tanh((y(iy)-y2)/ell));
  y(iy+1) = y(iy)+dy;
  iy = iy+1;
end %while
y=[-fliplr(y),y];

% x=[-fliplr(x(2:end)),x];

end % function