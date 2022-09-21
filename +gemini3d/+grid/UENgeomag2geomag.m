function [alt,mlon,mlat] = UENgeomag2geomag(zUEN,xUEN,yUEN,reflon,reflat)
arguments
  zUEN {mustBeNumeric}
  xUEN {mustBeNumeric}
  yUEN {mustBeNumeric}
  reflon {mustBeNumeric}
  reflat {mustBeNumeric}
end

%upward distance
Re=6370e3;
alt=zUEN;

%Northward angular distance
gamma2=yUEN/Re;                  %must retain the sign of x3
reftheta=(90-reflat)*pi/180;      %radians
theta=reftheta-gamma2;      %minus because distance north is against theta's directio
mlat=90-theta*180/pi;

%Eastward angular distance
gamma1=xUEN/Re/sin(reftheta);    %must retain the sign of x2, just use theta of center of grid
phi=reflon*pi/180+gamma1;
mlon=phi*180/pi;

end %function
