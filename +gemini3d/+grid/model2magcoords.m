function [parmi, alti,mloni,mlati] = model2magcoords(xg,parm,lalt,llon,llat,altlims,mlonlims,mlatlims)

%Grid the scalar GEMINI output data in parm onto a regular *geomagnetic* coordinates
%grid.  By default create a linearly spaced output grid based on
%user-provided limits (or grid limits).  Needs to be updated to deal with
%2D input grids; can interpolate from 3D grids to 2D slices...
%
%  [alt,mlon,mlat,parmi]=model2magcoords(xg,parm,lalt,llon,llat,altlims,mlonlims,mlatlims)


%% Need at least two arguments, set defaults an necessary
narginchk(2,8);

mlon=xg.phi*180/pi;
mlat=90-xg.theta*180/pi;
alt=xg.alt;
lx1=xg.lx(1); lx2=xg.lx(2); lx3=xg.lx(3);
inds1=3:lx1+2; inds2=3:lx2+2; inds3=3:lx3+2;
x1=xg.x1(inds1); x2=xg.x2(inds2); x3=xg.x3(inds3);

if (nargin<8)    %default to using grid limits if not given
    altlims=[min(alt(:))+0.0001,max(alt(:))-0.0001];   %make sure we say just inside model limits...
    mlonlims=[min(mlon(:))+0.0001,max(mlon(:))-0.0001];
    mlatlims=[min(mlat(:))+0.0001,max(mlat(:))-0.0001];
end %if
if (nargin<5)    %default to some number of grid points if not given
    lalt=150; llon=150; llat=150;
end %if

%% Define a regular mesh of a set number of points that encompasses the grid (or part of the grid)
alti=linspace(altlims(1),altlims(2),lalt);
mloni=linspace(mlonlims(1),mlonlims(2),llon);
mlati=linspace(mlatlims(1),mlatlims(2),llat);
[MLONi,ALTi,MLATi]=meshgrid(mloni,alti,mlati);


%% Identify the type of grid that we are using
minh1=min(xg.h1(:));
maxh1=max(xg.h1(:));
if (abs(minh1-1)>1e-4 || abs(maxh1-1)>1e-4)    %curvilinear grid
    flagcurv=1;
else                                           %cartesian grid
    flagcurv=0;
% elseif others possible...
end %if


%% Compute the coordinates of the intended interpolation grid IN THE MODEL SYSTEM/BASIS.
%There needs to be a separate transformation here for each coordinate system that the model
% may use...
if (flagcurv==1)
    [qi,pei,phii]= gemscr.geomag2dipole(ALTi,MLONi,MLATi);
    x1i=qi(:); x2i=pei(:); x3i=phii(:);
elseif (flagcurv==0)
    [zUENi,xUENi,yUENi]= gemscr.geomag2UENgeomag(ALTi,MLONi,MLATi);
    x1i=zUENi(:); x2i=xUENi(:); x3i=yUENi(:);
else
    error('Unsupported grid type...');
end %if


%% Execute plaid interpolation
[X2,X1,X3]=meshgrid(x2,x1,x3);
parmi=interp3(X2,X1,X3,parm,x2i,x1i,x3i);
parmi=reshape(parmi,[lalt,llon,llat]);

end %function model2magcoords
