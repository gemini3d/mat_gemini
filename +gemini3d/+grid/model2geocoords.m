function [parmi,alti,gloni,glati]=model2geocoords(xg,parm,lalt,llon,llat,altlims,glonlims,glatlims)
arguments
  xg (1,1) struct
  parm {mustBeReal}
  lalt (1,1) {mustBePositive,mustBeInteger} = 150
  llon (1,1) {mustBePositive,mustBeInteger} = 150
  llat (1,1) {mustBePositive,mustBeInteger} = 150
  altlims (1,2) {mustBeReal} = [min(xg.alt, [], 'all')+0.0001, max(xg.alt, [], 'all')-0.0001]
  glonlims (1,2) {mustBeReal} = [nan,nan]
  glatlims (1,2) {mustBeReal} = [nan,nan]
end
%Grid the GEMINI output data in parm onto a regular *geographic* coordinates
%grid.  By default create a linearly spaced output grid based on
%user-provided limits (or grid limits).  Needs to be updated to deal with
%2D grids...
%
%  [alt,glon,glat,parmi]=model2geocoords(xg,parm,lalt,llon,llat,altlims,glonlims,glatlims)

%these lines break backward compatibility due to an old error in the grid
%generation code that was fixed as of commit:  75f359801fb237c55251277bc623f738106dd82d
%glon=xg.glon;
%glat=xg.glat;
[glat,glon] = gemini3d.geomag2geog(xg.theta,xg.phi);    %use alternative calculation that always works
thetactr=mean(xg.theta, 'all');
phictr=mean(xg.phi, 'all');
mlatctr=90- rad2deg(thetactr);
mlonctr=rad2deg(phictr);

lx1=xg.lx(1); lx2=xg.lx(2); lx3=xg.lx(3);
inds1=3:lx1+2; inds2=3:lx2+2; inds3=3:lx3+2;
x1=xg.x1(inds1); x2=xg.x2(inds2); x3=xg.x3(inds3);

% force wrapping of longitude
%if wraplon
glon(glon < 180) = glon(glon < 180)+360;
%end %if

if any(isnan(glonlims))
  glonlims=[min(glon, [], 'all'), max(glon, [], 'all')];
end
if any(isnan(glatlims))
  glatlims=[min(glat, [], 'all'), max(glat, [], 'all')];
end

%% Define a regular mesh of a set number of points that encompasses the grid (or part of the grid)
alti=linspace(altlims(1),altlims(2),lalt);
gloni=linspace(glonlims(1),glonlims(2),llon);
glati=linspace(glatlims(1),glatlims(2),llat);
[GLONi,ALTi,GLATi]=meshgrid(gloni,alti,glati);


%% Identify the type of grid that we are using
minh1=min(xg.h1, [], 'all');
maxh1=max(xg.h1, [], 'all');
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
    [qi,pei,phii]= gemini3d.grid.geog2dipole(ALTi,GLONi,GLATi);
    x1i=qi(:); x2i=pei(:); x3i=phii(:);
elseif (flagcurv==0)
    [zUENi,xUENi,yUENi]= gemini3d.grid.geog2UENgeomag(ALTi,GLONi,GLATi,mlonctr,mlatctr);
    x1i=zUENi(:); x2i=xUENi(:); x3i=yUENi(:);
else
    error('Unsupported grid type...');
end %if


%% Execute plaid interpolation
[X2,X1,X3]=meshgrid(x2,x1,x3);
parmi=interp3(X2,X1,X3,parm,x2i,x1i,x3i);
parmi=reshape(parmi,[lalt,llon,llat]);

end %function model2geocoords
