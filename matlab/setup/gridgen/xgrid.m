function x = xgrid(xdist,lxp,xparms)

narginchk(2,3)
validateattributes(xdist, {'numeric'}, {'scalar','nonnegative'}, mfilename, 'one-way x-distance from origin (meters)',1)
validateattributes(lxp, {'numeric'}, {'scalar','integer','positive'}, mfilename, 'number of x-points',2)
if (~exist('xparms','var'))
    xparms=[];
end %if

xmin = -xdist/2;
xmax = xdist/2;

if (isempty(xparms))     %uniform grid being created...
    if lxp == 1  % degenerate dimension
        % add 2 ghost cells on each side
        x = linspace(xmin, xmax, lxp + 4);
    else
        % exclude the ghost cells when setting extents
        x = linspace(xmin, xmax, lxp);
        dx1 = x(2) - x(1);
        dxn = x(end) - x(end-1);
        % now tack on ghost cells so they are outside user-specified region
        x=[x(1)-2*dx1, x(1)-dx1, x, x(end)+dxn, x(end)+2*dxn];
    end
else   %nonuniform grid; assume we are degrading resolution near the edges - this will ignore lxp
    degdist=xparms(1);    % distance from boundary at which we start to degrade resolution
    dx0=xparms(2);        % min step size for grid
    dxincr=xparms(3);     % max step size increase for grid
    ell=xparms(4);        % transition length of degradation
    x2=xmax-degdist;
    
    %x(1)=0;
    x(1)=1/2*dx0;    %start offset from zero so we can have an even number (better for mpi)
    gridctr=0;
    ix=1;
    while (x(ix)<xmax)
        dx=dx0+dxincr*(1/2+1/2*tanh((x(ix)-x2)/ell));
        x(ix+1)=x(ix)+dx;
        ix=ix+1;
    end %while
    x=[-fliplr(x),x];
    
    %x=[-fliplr(x(2:end)),x];
end %if


end % function
