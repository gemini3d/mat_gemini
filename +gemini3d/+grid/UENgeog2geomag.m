function [zUENmag,xUENmag,yUENmag]=UENgeog2geomag(zUENgeo,xUENgeo,yUENgeo,reflon,reflat)
%% Converts input geographic UEN coordinates into magnetic UEN
arguments
  zUENgeo {mustBeNumeric}
  xUENgeo {mustBeNumeric}
  yUENgeo {mustBeNumeric}
  reflon {mustBeNumeric}
  reflat {mustBeNumeric}
end

%UPWARD DISTANCE
Re=6370e3;
alt=zUENgeo;

%Northward angular distance
gamma2=yUENgeo/Re;                  %must retain the sign of x3
refgeogtheta=(90-reflat)*pi/180;      %radians
thetageog=refgeogtheta-gamma2;      %minus because distance north is against theta's directio
glat=90-thetageog*180/pi;

%Eastward angular distance
gamma1=xUENgeo/Re/sin(refgeogtheta);    %must retain the sign of x2, just use theta of center of grid
refgeoglon=reflon;
phigeog=refgeoglon*pi/180+gamma1;
glon=phigeog*180/pi;

%Now convert the geographic to magnetic using GEMINI transformation
[theta,phi] = gemini3d.geog2geomag(glat,glon);

%Now convert the theta,phi to distances north and east, respectively
[refmagtheta,refmagphi] = gemini3d.geog2geomag(reflat,reflon);

%Convert magnetic coords into UEN magnetic by warping onto Earth's surface
yUENmag=-1*(theta-refmagtheta)*Re;             %minus due to distance south in theta direction
xUENmag=(phi-refmagphi)*Re*sin(refmagtheta);   %east dist same as phi direction
zUENmag=alt;

end
