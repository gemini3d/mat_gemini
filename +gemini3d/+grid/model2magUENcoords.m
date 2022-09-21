function [parmi, zUENi,xUENi,yUENi] = model2magUENcoords(xg,parm,lz,lx,ly,zlims,xlims,ylims)

%Grid the GEMINI output data in parm onto a regular *geomagnetic* coordinates
%grid.  By default create a linearly spaced output grid based on
%user-provided limits (or grid limits).  Needs to be updated to deal with
%2D grids...

%% Need at least two arguments, set defaults an necessary
narginchk(2,8);

mlon=xg.phi*180/pi;
mlat=90-xg.theta*180/pi;
reflat=mean(mlat(:));
reflon=mean(mlon(:));
alt=xg.alt;
[zUEN,xUEN,yUEN]= gemscr.geomag2UENgeomag(alt,mlon,mlat);

lx1=xg.lx(1); lx2=xg.lx(2); lx3=xg.lx(3);
inds1=3:lx1+2; inds2=3:lx2+2; inds3=3:lx3+2;
x1=xg.x1(inds1); x2=xg.x2(inds2); x3=xg.x3(inds3);

if (nargin<5)    %default to some number of grid points if not given
    lz=150; lx=150; ly=150;
end %if
if (nargin<8)    %default to using grid limits if not given
    zlims=[min(zUEN(:))+1,max(zUEN(:))-1];   %stay just inside given grid
    xlims=[min(xUEN(:))+1,max(xUEN(:))-1];
    ylims=[min(yUEN(:))+1,max(yUEN(:))-1];
end %if


%% Define a regular mesh of a set number of points that encompasses the grid (or part of the grid)
zUENi=linspace(zlims(1),zlims(2),lz);
xUENi=linspace(xlims(1),xlims(2),lx);
yUENi=linspace(ylims(1),ylims(2),ly);
[XUENi,ZUENi,YUENi]=meshgrid(xUENi,zUENi,yUENi);


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
    [ALTi,MLONi,MLATi]= gemscr.UENgeomag2geomag(ZUENi,XUENi,YUENi,reflon,reflat);
    [qi,pei,phii]= gemscr.geomag2dipole(ALTi,MLONi,MLATi);
    x1i=qi(:); x2i=pei(:); x3i=phii(:);
elseif (flagcurv==0)
%    x1i=zUENi(:); x2i=xUENi(:); x3i=yUENi(:);
    x1i=ZUENi(:); x2i=XUENi(:); x3i=YUENi(:);
else
    error('Unsupported grid type...');
end %if


%% Execute plaid interpolation
[X2,X1,X3]=meshgrid(x2,x1,x3);
parmi=interp3(X2,X1,X3,parm,x2i,x1i,x3i);
parmi=reshape(parmi,[lz,lx,ly]);

end %function model2magUENcoords
